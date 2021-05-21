variable "hub_or_spoke" {
  description = "Value can be hub or spoke and will determine mappings for vpn template"
  type        = string
  default     = "spoke"
}

variable "vpn_mappings" {
  description = "A map of VPN objects to make VPNs for"
  type = map(object({
    tunnel_name   = string
    interface     = string
    psksecret     = string
    nat_traversal = string
    external_ip = object({
      hub   = string
      spoke = string
    })
    tunnel_ip = object({
      hub   = string
      spoke = string
    })
  }))
}

variable "create_system_interfaces" {
  description = "A boolean to specify if a system interface should be explicitly created for IPsec site-to-site VPN. As of FortiOS 7.0.0, a valid system interface is created automatically when a phase1 interface is created."
  type = bool
  default = false
}