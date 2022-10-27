<!-- BEGIN_TF_DOCS -->
# terraform-fortios-ikev2-hub-spoke-vpn-generator

GitHub: [StratusGrid/terraform-fortios-ikev2-hub-spoke-vpn-generator](https://github.com/StratusGrid/terraform-fortios-ikev2-hub-spoke-vpn-generator)

This module takes a list of VPN configuration objects and makes a VPN for each side.

Additionally, it outputs a map of the tunnel interface => IPs to dynamically add to OSPF, Firewall rules, etc.

There is the need to make the module more dynamic and expandable by using variables where appropriate. May be worth having a vpn_mappings_advanced, then combining the maps in a local with default values or similar in the future, to allow things to be optionally defined without introducing breaking changes.

## Example Configuration:

```hcl
#### tfvars:
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

#### Module definition:
module "vpn_mappings" {
  source = "./modules/hub-spoke-vpn-generator"

  hub_or_spoke = "hub"
  vpn_mappings = var.vpn_mappings
}

#### Dynamic OSPF:
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
      cost           = 10
      dead_interval  = 40
      hello_interval = 10
      network_type   = "point-to-point"
      mtu            = 1420
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
---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_fortios"></a> [fortios](#requirement\_fortios) | >= 1.10 |

## Resources

| Name | Type |
|------|------|
| [fortios_system_interface.this](https://registry.terraform.io/providers/fortinetdev/fortios/latest/docs/resources/system_interface) | resource |
| [fortios_vpnipsec_phase1interface.this](https://registry.terraform.io/providers/fortinetdev/fortios/latest/docs/resources/vpnipsec_phase1interface) | resource |
| [fortios_vpnipsec_phase2interface.this](https://registry.terraform.io/providers/fortinetdev/fortios/latest/docs/resources/vpnipsec_phase2interface) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hub_or_spoke"></a> [hub\_or\_spoke](#input\_hub\_or\_spoke) | Value can be hub or spoke and will determine mappings for vpn template | `string` | `"spoke"` | no |
| <a name="input_vpn_mappings"></a> [vpn\_mappings](#input\_vpn\_mappings) | A map of VPN objects to make VPNs for | <pre>map(object({<br>    tunnel_name   = string<br>    interface     = string<br>    psksecret     = string<br>    nat_traversal = string<br>    external_ip = object({<br>      hub   = string<br>      spoke = string<br>    })<br>    tunnel_ip = object({<br>      hub   = string<br>      spoke = string<br>    })<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_tunnel_interfaces"></a> [local\_tunnel\_interfaces](#output\_local\_tunnel\_interfaces) | A map of the tunnel interface names to add to firewall policies. |
| <a name="output_local_tunnel_ips"></a> [local\_tunnel\_ips](#output\_local\_tunnel\_ips) | A map of the tunnel interface => IPs to dynamically add to OSPF, FW rules, etc. |

---

<span style="color:red">Note:</span> Manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml .`
<!-- END_TF_DOCS -->