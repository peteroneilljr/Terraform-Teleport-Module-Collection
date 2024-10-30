# ---------------------------------------------------------------------------- #
# EC2 agent_nodename Instance Profile - Console Access
# ---------------------------------------------------------------------------- #
resource "aws_iam_role" "console_access" {
  name               = local.aws_role.console
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

resource "aws_iam_instance_profile" "console_access" {
  name = "${local.aws_role.console}Profile"
  role = aws_iam_role.console_access.name
}

# ---------------------------------------------------------------------------- #
# Teleport IAM Assume RO Role
# ---------------------------------------------------------------------------- # 
resource "aws_iam_role" "teleport_assume_ro" {
  name               = local.aws_role.ro
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.console_access.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_assume_ro" {
  role       = aws_iam_role.teleport_assume_ro.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
# ---------------------------------------------------------------------------- #
# Teleport IAM Assume Admin Role
# ---------------------------------------------------------------------------- # 
resource "aws_iam_role" "teleport_assume_admin" {
  name               = local.aws_role.admin
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.console_access.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_assume_admin" {
  role       = aws_iam_role.teleport_assume_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ---------------------------------------------------------------------------- #
# Teleport IAM Assume Database Admin Role
# ---------------------------------------------------------------------------- # 
resource "aws_iam_role" "teleport_assume_db_admin" {
  name               = local.aws_role.db
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.console_access.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_assume_db_admin" {
  role       = aws_iam_role.teleport_assume_db_admin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/DatabaseAdministrator"
}

# ---------------------------------------------------------------------------- #
# Teleport IAM Assume Network Admin Role
# ---------------------------------------------------------------------------- # 
resource "aws_iam_role" "teleport_assume_network_admin" {
  name               = local.aws_role.net
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.console_access.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_assume_network_admin" {
  role       = aws_iam_role.teleport_assume_network_admin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}
# ---------------------------------------------------------------------------- #
# Teleport IAM Assume EC2 Admin Role
# ---------------------------------------------------------------------------- # 
resource "aws_iam_role" "teleport_assume_ec2_admin" {
  name               = local.aws_role.ec2
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.console_access.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_assume_ec2_admin" {
  role       = aws_iam_role.teleport_assume_ec2_admin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}

# ---------------------------------------------------------------------------- #
# Deploy Teleport Agent 
# ---------------------------------------------------------------------------- #
module "teleport_aws" {
  source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  teleport_agent_roles = ["Node", "App"]

  teleport_proxy_address = var.teleport_proxy_address
  teleport_edition       = var.teleport_edition
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }

  aws_key_pair         = var.aws_key_pair
  aws_instance_profile = aws_iam_instance_profile.console_access.name

  teleport_nodename = "aws-agent"

  teleport_apps = {
    "awsconsole" = {
      "uri" = "https://console.aws.amazon.com/"
      "cloud" = "AWS"
      "labels" = {
        "cloud" = "aws"
        "env"   = "dev"
      }
    }
    "awsconsole-admin" = {
      "uri" = "https://console.aws.amazon.com/"
      "cloud" = "AWS"
      "labels" = {
        "cloud" = "aws"
        "env"   = "prod"
      }
    }
  }

}

