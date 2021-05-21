# Resource Docs: https://registry.terraform.io/providers/fortinetdev/fortios/latest/docs/resources/fortios_vpnipsec_phase2interface
locals {
  # if hub_or_spoke = hub, local is hub
  local_selector = {
    hub   = "hub"
    spoke = "spoke"
  }
  # if hub_or_spoke = hub, remote is spoke
  remote_selector = {
    hub   = "spoke"
    spoke = "hub"
  }
}

resource "fortios_vpnipsec_phase1interface" "this" {
  for_each = var.vpn_mappings

  name         = each.value.tunnel_name
  interface    = each.value.interface
  ike_version  = "2"
  peertype     = "any"
  proposal     = "aes256-sha256"
  dhgrp        = "21"
  local_gw     = lookup(each.value.external_ip, lookup(local.local_selector, var.hub_or_spoke, null), null)
  remote_gw    = lookup(each.value.external_ip, lookup(local.remote_selector, var.hub_or_spoke, null), null)
  psksecret    = each.value.psksecret
  nattraversal = each.value.nat_traversal

  ### Random Garbage:
  net_device = "disable"
}

resource "fortios_vpnipsec_phase2interface" "this" {
  for_each = var.vpn_mappings

  name           = fortios_vpnipsec_phase1interface.this[each.key].name
  phase1name     = fortios_vpnipsec_phase1interface.this[each.key].name
  pfs            = "enable"
  proposal       = "aes256-sha256"
  dhgrp          = "21"
  keylifeseconds = 3600
}

resource "fortios_system_interface" "this" {
  for_each = var.vpn_mappings

  name        = each.value.tunnel_name
  description = each.value.tunnel_name
  type        = "tunnel"
  vdom        = "root"
  allowaccess = "ping https ssh http"
  ip          = lookup(each.value.tunnel_ip, lookup(local.local_selector, var.hub_or_spoke, null), null)
  remote_ip   = lookup(each.value.tunnel_ip, lookup(local.remote_selector, var.hub_or_spoke, null), null)
  tcp_mss     = 1400
}