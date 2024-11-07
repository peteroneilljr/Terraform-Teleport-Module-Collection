output "teleport_windows_hosts" {
  description = "description"

  value = {
    for index, host in var.windows_machines :
    host => {
      "addr" = module.windows_instances["${host}"].private_ip
      "labels" = {
        "env" = "${host}"
      }
    }
  }
}