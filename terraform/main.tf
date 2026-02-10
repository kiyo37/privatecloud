provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = var.proxmox_insecure
}

resource "proxmox_virtual_environment_vm" "vm" {
  count     = length(var.vm_map) > 0 ? 0 : 1
  name      = var.vm_name
  node_name = var.proxmox_node_name
  vm_id     = var.vm_id
  tags      = var.vm_tags

  clone {
    vm_id     = var.vm_template_id
    node_name = var.proxmox_node_name
    full      = true
  }

  cpu {
    cores = var.vm_cpu_cores
  }

  memory {
    dedicated = var.vm_memory_mb
  }

  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = "${var.vm_disk_gb}G"
  }

  network_device {
    model   = "virtio"
    bridge  = var.vm_bridge
    vlan_id = var.vm_vlan_id
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.vm_ipv4_address
        gateway = var.vm_ipv4_gateway
      }
    }

    user_account {
      username = var.ssh_username
      ssh_keys = [file(var.ssh_public_key_path)]
    }
  }

  agent {
    enabled = var.qemu_guest_agent
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
  for_each  = length(var.vm_map) > 0 ? var.vm_map : {}
  name      = each.value.name
  node_name = var.proxmox_node_name
  vm_id     = each.value.vm_id
  tags      = try(each.value.tags, ["terraform"])

  clone {
    vm_id     = var.vm_template_id
    node_name = var.proxmox_node_name
    full      = true
  }

  cpu {
    cores = each.value.cpu_cores
  }

  memory {
    dedicated = each.value.memory_mb
  }

  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = "${each.value.disk_gb}G"
  }

  network_device {
    model   = "virtio"
    bridge  = var.vm_bridge
    vlan_id = var.vm_vlan_id
  }

  initialization {
    ip_config {
      ipv4 {
        address = try(each.value.ipv4_address, "dhcp")
        gateway = try(each.value.ipv4_gateway, null)
      }
    }

    user_account {
      username = var.ssh_username
      ssh_keys = [file(var.ssh_public_key_path)]
    }
  }

  agent {
    enabled = var.qemu_guest_agent
  }
}
