output "vm_name" {
  value = length(var.vm_map) > 0 ? null : proxmox_virtual_environment_vm.vm[0].name
}

output "vm_id" {
  value = length(var.vm_map) > 0 ? null : proxmox_virtual_environment_vm.vm[0].vm_id
}

output "vm_ipv4_addresses" {
  value = length(var.vm_map) > 0 ? [] : try(proxmox_virtual_environment_vm.vm[0].ipv4_addresses, [])
}

output "vms" {
  value = length(var.vm_map) > 0 ? {
    for k, v in proxmox_virtual_environment_vm.vms :
    k => {
      name            = v.name
      vm_id           = v.vm_id
      ipv4_addresses  = try(v.ipv4_addresses, [])
    }
  } : {}
}
