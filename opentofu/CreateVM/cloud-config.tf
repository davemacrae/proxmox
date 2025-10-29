resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.virtual_environment_node_name

  count = var.num_vm
  source_file {
    path = "user-data-cloud-config-${count.index}.yaml"
  }
}

resource "local_file" "cloud_config" {
  count = var.num_vm
  filename = "user-data-cloud-config-${count.index}.yaml"
  content = templatefile("${path.module}/script.yml.tpl", { instance_name =  "test-ubuntu-${count.index}"})
}

