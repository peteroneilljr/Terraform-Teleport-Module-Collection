
resource "aws_iam_instance_profile" "rds_postgresql" {
  name  = "${var.prefix}RdsProfile"
  role  = aws_iam_role.rds_postgresql.name
}
resource "aws_iam_role" "rds_postgresql" {
  name  = "${var.prefix}RdsAssume"

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
resource "aws_iam_role_policy" "rds_postgresql" {
  name  = "${var.prefix}RdsPolicy"
  role  = aws_iam_role.rds_postgresql.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole",
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters",
        "rds:ModifyDBInstance",
        "rds:ModifyDBCluster",
        "rds-db:connect"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}