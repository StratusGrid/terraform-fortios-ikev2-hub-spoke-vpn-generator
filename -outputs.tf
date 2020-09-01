output "local_tunnel_ips" {
  value = {
    for interface in fortios_system_interface.this:
        interface.name => interface.ip
    }
}