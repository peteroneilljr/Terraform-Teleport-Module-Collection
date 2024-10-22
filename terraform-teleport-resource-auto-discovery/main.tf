# ---------------------------------------------------------------------------- #
# Assign EC2 SSM Profile for management
# ---------------------------------------------------------------------------- #
resource "aws_iam_role_policy_attachment" "managed_instance" {
  count      = var.create ? 1 : 0
  role       = aws_iam_role.managed_instance[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role" "managed_instance" {
  count = var.create ? 1 : 0
  name  = "${var.prefix}ManagedInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "managed_instance" {
  count = var.create ? 1 : 0
  name  = "${var.prefix}ManagedInstanceProfile"
  role  = aws_iam_role.managed_instance[count.index].name
}

# ---------------------------------------------------------------------------- #
# Discovery SSM Documents
# ---------------------------------------------------------------------------- #  
resource "teleport_provision_token" "discovery_token" {
  # Token used to register discovered Nodes
  count = var.create ? 1 : 0

  version = "v2"
  spec = {

    join_method = "iam"

    roles = [
      "Node",
    ]

    allow = [
      { aws_account = var.aws_account },
    ]

  }
  metadata = {
    name    = "discovery-token"
    expires = null # Long lived static token for discovery

    labels = {
      "teleport.dev/origin" = "dynamic"
    }
  }
}

# ---------------------------------------------------------------------------- #
# aws ssm documents
# ---------------------------------------------------------------------------- #

resource "aws_iam_policy" "auto_discovery" {
  count = var.create ? 1 : 0

  name = "${var.prefix}Ec2AutoDiscoveryPolicy"
  path = "/"

  policy = data.aws_iam_policy_document.auto_discovery[count.index].json
}
data "aws_iam_policy_document" "auto_discovery" {
  count = var.create ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ssm:CreateDocument",
      "ssm:DescribeInstanceInformation",
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
      "ssm:SendCommand"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "auto_discovery" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.auto_discovery[count.index].name
  policy_arn = aws_iam_policy.auto_discovery[count.index].arn
}
resource "aws_iam_role" "auto_discovery" {
  count = var.create ? 1 : 0

  name = "${var.prefix}Ec2AutoDiscoveryRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "auto_discovery" {
  count = var.create ? 1 : 0

  name = "${var.prefix}Ec2AutoDiscoveryProfile"
  role = aws_iam_role.auto_discovery[count.index].name
}

resource "aws_ssm_document" "auto_discovery" {
  count = var.create ? 1 : 0

  name            = "${var.prefix}TeleportEc2AutoDiscovery"
  document_format = "YAML"
  document_type   = "Command"

  content = <<DOC
schemaVersion: '2.2'
description: aws:runShellScript
parameters:
  token:
    type: String
    description: "(Required) The Teleport invite token to use when joining the cluster."
  scriptName:
    type: String
    description: "(Required) The Teleport installer script to use when joining the cluster."
mainSteps:
- action: aws:downloadContent
  name: downloadContent
  inputs:
    sourceType: "HTTP"
    destinationPath: "/tmp/installTeleport.sh"
    sourceInfo:
      url: "https://${var.teleport_proxy_address}:443/webapi/scripts/installer/{{ scriptName }}"
- action: aws:runShellScript
  name: runShellScript
  inputs:
    timeoutSeconds: '300'
    runCommand:
      - /bin/sh /tmp/installTeleport.sh "{{ token }}"
DOC
}
# ---------------------------------------------------------------------------- #
# Create Instances to be discovered
# ---------------------------------------------------------------------------- #
module "auto_discovery_nodes" {
  source = "terraform-aws-modules/ec2-instance/aws"

  create = var.create

  for_each = toset([
    "dev",
  ])

  name = "teleport-${each.key}"

  user_data = <<USER
  hostname "teleport-${each.key}"
  USER

  iam_instance_profile = try(aws_iam_instance_profile.managed_instance[0].name, "")

  instance_type          = "t3.nano"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [var.aws_security_group_id]
  subnet_id              = var.aws_subnet_id

  ami                = var.aws_ami
  ignore_ami_changes = true

  metadata_options = {
    http_endpoint : "enabled"
    http_tokens : "required"
    instance_metadata_tags : "disabled"
  }

  tags = {
    "env"       = "dev"
    "discovery" = "ec2"
    "os"        = "amzn-linux"
  }
}
# ---------------------------------------------------------------------------- #
# Create Teleport Agent with Discovery Service Running
# ---------------------------------------------------------------------------- #
module "auto_discovery_agent" {
  source = "../terraform-teleport-agent"

  cloud = "AWS"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  agent_nodename = "discovery-agent"

  teleport_agent_roles = ["Discovery"]

  teleport_proxy_address         = var.teleport_proxy_address
  teleport_version               = var.teleport_version
  teleport_discovery_token       = try(teleport_provision_token.discovery_token[0].metadata.name, "")
  teleport_discovery_ssm_install = try(aws_ssm_document.auto_discovery[0].name, "")
  teleport_ssh_labels = {
    "type" = "agent"
  }
  aws_key_pair         = var.aws_key_name
  aws_instance_profile = try(aws_iam_instance_profile.auto_discovery[0].name, null)

  teleport_discovery_tags = {
    "discovery" = "ec2"
  }
}