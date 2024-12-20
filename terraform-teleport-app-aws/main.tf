# ---------------------------------------------------------------------------- #
# EC2 agent_nodename Instance Profile - Console Access
# ---------------------------------------------------------------------------- #
resource "aws_iam_role" "console_access" {
  count = can(var.aws_iam_role_name) ? 0 : 1

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
  role = data.aws_iam_role.console_access.name
}

data "aws_iam_role" "console_access" {
  name = try(var.aws_iam_role_name, aws_iam_role.console_access[0].name)
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
        "AWS": "${data.aws_iam_role.console_access.arn}"
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
        "AWS": "${data.aws_iam_role.console_access.arn}"
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
        "AWS": "${data.aws_iam_role.console_access.arn}"
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
        "AWS": "${data.aws_iam_role.console_access.arn}"
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
        "AWS": "${data.aws_iam_role.console_access.arn}"
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


