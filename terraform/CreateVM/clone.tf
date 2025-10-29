resource "proxmox_virtual_environment_vm" "ubuntu_clone" {
  count = var.num_vm
  name      = "ubuntu-clone-${count.index + 1}"
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
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[count.index].id
  }
}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.ubuntu_clone[*].ipv4_addresses[1][0]
}
