resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  count = var.num_vm
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: test-ubuntu-${count.index}
    EOF

    file_name = "meta-data-cloud-config-${count.index}.yaml"
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.virtual_environment_node_name
  source_file {
    path = "script.yml"
  }
}
