output "local_tunnel_ips" {
//TODO: add logic to output tunnel IPs if no system interfaces are created by terraform.
  description = "A map of the tunnel interface => IPs to dynamically add to OSPF, FW rules, etc."
  value = var.create_system_interfaces == true ?
  {
    for interface in fortios_system_interface.this :
    interface.name => interface.ip
  } :
  {
    for interface in data.fortios_system_interface.this :
    interface.name => interface.ip
  }
}