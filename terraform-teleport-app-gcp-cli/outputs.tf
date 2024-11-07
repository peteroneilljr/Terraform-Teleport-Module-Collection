output "userconfig" {
  value     = module.teleport_gcp.userconfig
  sensitive = true
}
