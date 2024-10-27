output userconfig {
  value       = local_file.teleport_config.content
  sensitive   = true
}
