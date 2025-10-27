resource "proxmox_virtual_environment_vm" "ubuntu_clone" {
  # count = 1
  # name      = "ubuntu-clone${count.index + 1}"
  name      = "ubuntu-clone"
  node_name = var.virtual_environment_node_name

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 2048
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

output "vm_ipv4_address" {
  # value = proxmox_virtual_environment_vm.ubuntu_clone[count.index].ipv4_addresses[1][0]
  value = proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]
}
