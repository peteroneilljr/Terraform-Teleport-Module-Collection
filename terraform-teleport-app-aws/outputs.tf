output "iam_roles" {
  description = "description"
  value = [
    aws_iam_role.teleport_assume_ro.arn,
    aws_iam_role.teleport_assume_admin.arn,
    aws_iam_role.teleport_assume_db_admin.arn,
    aws_iam_role.teleport_assume_network_admin.arn,
    aws_iam_role.teleport_assume_ec2_admin.arn,
  ]
}
output "iam_console_access_profile" {
  value       = aws_iam_instance_profile.console_access.name
  description = "description"
}
output "iam_console_access_arn" {
  value       = data.aws_iam_role.console_access.arn
  description = "description"
}
output "iam_admin_arn" {
  value       = aws_iam_role.teleport_assume_admin.arn
  description = "description"
}
output "iam_db_admin_arn" {
  value       = aws_iam_role.teleport_assume_db_admin.arn
  description = "description"
}
output "iam_ec2_admin_arn" {
  value       = aws_iam_role.teleport_assume_ec2_admin.arn
  description = "description"
}
output "iam_network_admin_arn" {
  value       = aws_iam_role.teleport_assume_network_admin.arn
  description = "description"
}

output "iam_read_only_arn" {
  value       = aws_iam_role.teleport_assume_ro.arn
  description = "description"
}

# ---------------------------------------------------------------------------- #
# example for when adding new policies
# ---------------------------------------------------------------------------- #
# output iam_read_only_arn {
#   value       = module.read_only.arn
#   description = "description"
# }