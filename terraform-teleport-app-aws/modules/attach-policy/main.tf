locals {
  # splits the arn of the policy to grab name at the end
  arn_str = split("/", var.policy_arn)
  arn_last = length(local.arn_str)-1
  name = element(local.arn_str, local.arn_last)
}

resource "aws_iam_role" "this" {
  name               = "${var.prefix}${local.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.console_access_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn
}
