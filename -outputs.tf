output "local_tunnel_ips" {
//TODO: add logic to output tunnel IPs if no system interfaces are created by terraform.
  description = "A map of the tunnel interface => IPs to dynamically add to OSPF, FW rules, etc."
  value = {
    for interface in fortios_system_interface.this :
    interface.name => interface.ip
  }
}