variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  default     = "https://192.168.1.50:8006"
}

variable "proxmox_api_token_id" {
  description = "API token ID (e.g. terraform@pve!tf)"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Allow self-signed TLS"
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "vm_template_id" {
  description = "Cloud-Init template VM ID"
  type        = number
  default     = 9000
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "vm-ubuntu01"
}

variable "vm_id" {
  description = "VM ID"
  type        = number
  default     = 101
}

variable "vm_cpu_cores" {
  description = "CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "Memory (MB)"
  type        = number
  default     = 2048
}

variable "vm_disk_gb" {
  description = "Disk size (GB)"
  type        = number
  default     = 20
}

variable "vm_storage" {
  description = "Datastore for VM disk"
  type        = string
  default     = "local-lvm"
}

variable "vm_bridge" {
  description = "Bridge name"
  type        = string
  default     = "vmbr0"
}

variable "vm_vlan_id" {
  description = "VLAN ID (optional)"
  type        = number
  default     = null
}

variable "vm_ipv4_address" {
  description = "IPv4 address (use \"dhcp\" for DHCP)"
  type        = string
  default     = "dhcp"
}

variable "vm_ipv4_gateway" {
  description = "IPv4 gateway (DHCP時はnull)"
  type        = string
  default     = null
}

variable "ssh_username" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "qemu_guest_agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "vm_tags" {
  description = "VM tags"
  type        = list(string)
  default     = ["terraform"]
}

variable "vm_map" {
  description = "Map of VMs for multi-VM provisioning. If non-empty, single-VM vars are ignored."
  type = map(object({
    vm_id        = number
    name         = string
    cpu_cores    = number
    memory_mb    = number
    disk_gb      = number
    tags         = optional(list(string), ["terraform"])
    ipv4_address = optional(string, "dhcp")
    ipv4_gateway = optional(string)
  }))
  default = {}
}
