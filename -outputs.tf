output "local_tunnel_ips" {
  description = "A map of the tunnel interface => IPs to dynamically add to OSPF, FW rules, etc."
  value = {
    for interface in merge(fortios_system_interface.this, data.fortios_system_interface.this) :
    interface.name => interface.ip
  }
}

output "local_tunnel_interfaces" {
  description = "A map of the tunnel interface names to add to firewall policies."
  value = {
    for interface in fortios_vpnipsec_phase1interface.this :
    interface.interface => interface.local_gw
  }
}