# ---------------------------------------------------------------------------- #
# Assign EC2 SSM Profile for management
# ---------------------------------------------------------------------------- #
resource "aws_iam_role_policy_attachment" "managed_instance" {
  role       = aws_iam_role.managed_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role" "managed_instance" {
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
  name  = "${var.prefix}ManagedInstanceProfile"
  role  = aws_iam_role.managed_instance.name
}

# ---------------------------------------------------------------------------- #
# Discovery SSM Documents
# ---------------------------------------------------------------------------- #  
resource "teleport_provision_token" "discovery_token" {
  # Token used to register discovered Nodes

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

  name = "${var.prefix}Ec2AutoDiscoveryPolicy"
  path = "/"

  policy = data.aws_iam_policy_document.auto_discovery.json
}
data "aws_iam_policy_document" "auto_discovery" {

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

  role       = aws_iam_role.auto_discovery.name
  policy_arn = aws_iam_policy.auto_discovery.arn
}
resource "aws_iam_role" "auto_discovery" {

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

  name = "${var.prefix}Ec2AutoDiscoveryProfile"
  role = aws_iam_role.auto_discovery.name
}

resource "aws_ssm_document" "auto_discovery" {

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

  for_each = toset([
    "dev",
  ])

  name = "teleport-${each.key}"

  user_data = <<USER
  hostname "teleport-${each.key}"
  USER

  iam_instance_profile = aws_iam_instance_profile.managed_instance.name

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
