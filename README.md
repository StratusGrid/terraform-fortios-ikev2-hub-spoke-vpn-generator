### Description
This module takes a list of VPN configuration objects and makes a VPN for each side.

Additionally, it outputs a map of the tunnel interface => IPs to dynamically add to OSPF, FW rules, etc.

There is more variablization needed to make this more expandable. May be worth having a vpn_mappings_advanced, then combining the maps in a local with default values or similar down the road to allow things to be optionally defined without introducing breaking changes.

### Example Configuration
tfvars:
```
vpn_mappings = {
  my_vpn_wan1 = {
    tunnel_name   = "my-vpn-wan1"
    interface     = "wan1"
    psksecret     = "my-super-secret"
    nat_traversal = "forced"
    external_ip = {
      hub   = "8.8.8.8"
      spoke = "8.8.4.4"
    }
    tunnel_ip   = {
      hub   = "169.254.255.3 255.255.255.255"
      spoke = "169.254.255.4 255.255.255.255"
    }
  }
}
```
Module definition:
```
module "vpn_mappings" {
  source = "./modules/hub-spoke-vpn-generator"

  hub_or_spoke = "hub"
  vpn_mappings = var.vpn_mappings
}
```
Dynamic OSPF:
```
resource "fortios_router_ospf" "global" {
  router_id             = var.my_router_id

  area {
    id = "0.0.0.0"
  }

  dynamic "ospf_interface" {
    for_each = module.vpn_mappings.local_tunnel_ips

    content {
      name           = ospf_interface.key
      interface      = ospf_interface.key
      cost           = 12
      dead_interval  = 40
      hello_interval = 10
      network_type   = "point-to-point"
    }
  }

  dynamic "network" {
    for_each = module.vpn_mappings.local_tunnel_ips

    content {
      prefix = network.value
    }
  }

  log_neighbour_changes = "enable"

}
```