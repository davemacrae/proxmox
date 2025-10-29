# CreateVM

Provision virtual machines on a Proxmox cluster using OpenTofu (Terraform-compatible).

This module/configuration provides a reproducible way to create, configure, and destroy VMs on Proxmox VE. It is intended to be used with OpenTofu (or Terraform) and the community Proxmox provider.

## Features
- Create QEMU virtual machines
- Configure CPU, memory, disk, and network
- Inject SSH key and cloud-init userdata
- Support for templates or cloud images
- Outputs useful connection details

## Requirements
- OpenTofu or Terraform 1.5+
- Proxmox VE API accessible (pve-manager)
- Proxmox provider (e.g. sourceless/proxmox or Telmate/proxmox)
- SSH client for access after provisioning

## Quickstart

1. Install OpenTofu (or Terraform) and the Proxmox provider.
2. Place provider and variables files in the same directory as this module.
3. Initialize and apply:

```
opentofu init
opentofu plan -out plan.tfplan
opentofu apply plan.tfplan
```

(or `terraform` in place of `opentofu`)

## Typical resources used
- proxmox_vm_qemu (create VM)
- proxmox_storage_disk (provision disk or use disk config on proxmox_vm_qemu)
- proxmox_lxc (if LXC containers are desired instead of QEMU)
- cloud-init userdata for initial provisioning

## Outputs
- vm_id
- vm_ip

## Security / Best practices
- Use API tokens instead of username/password when possible.
- Do not commit secrets or tfstate files to source control; use remote state backends.
- Limit token permissions and rotate tokens regularly.
- Test in a non-production environment first.

## Troubleshooting
- API connectivity errors: verify URL, token, and network access.
- VM creation fails: check storage space, template path, and node availability.
- Cloud-init not applying: confirm cloud image supports cloud-init and correct userdata format.

## Contributing
- Open issues and PRs with clear repro steps.
- Keep changes small and document new variables and behaviors.

For more details and provider-specific options, consult the Proxmox provider documentation and OpenTofu/Terraform docs.