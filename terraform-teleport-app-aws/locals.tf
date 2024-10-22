locals {
  aws_role = {
    console = "${var.prefix}AwsConsoleAccess"
    ro      = "${var.prefix}AwsAssumeReadOnly"
    admin   = "${var.prefix}AwsAssumeAdmin"
    db      = "${var.prefix}AwsAssumeDatabaseAdmin"
    net     = "${var.prefix}AwsAssumeNetworkAdmin"
    ec2     = "${var.prefix}AwsAssumeEc2Admin"
  }
}