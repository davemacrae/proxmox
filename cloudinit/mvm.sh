#! /bin/bash

VMID=999
STORAGE=local-lvm
USER=dave

set -x
RELEASE=plucky
IMAGE="${RELEASE}-server-cloudimg-amd64.img"
IMAGE_URL="https://cloud-images.ubuntu.com/${RELEASE}/current/${RELEASE}-server-cloudimg-amd64.img"

rm -f ${IMAGE}

wget $IMAGE_URL -O ${IMAGE}

qemu-img resize ${IMAGE} 8G
qm destroy $VMID
qm create $VMID --name "ubuntu-${RELEASE}-template" --ostype l26 \
    --memory 1024 --balloon 0 \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --cpu host --socket 1 --cores 1 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0
qm importdisk $VMID ${IMAGE} $STORAGE > /dev/null 2>&1
qm set $VMID --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$VMID-disk-1,discard=on
qm set $VMID --boot order=virtio0
qm set $VMID --scsi1 $STORAGE:cloudinit

cp script.yml /var/lib/vz/snippets/ubuntu.yaml

qm set $VMID --cicustom "vendor=local:snippets/ubuntu.yaml"
qm set $VMID --tags ubuntu-template,plucky,cloudinit
qm set $VMID --ciuser $USER
qm set $VMID --sshkeys ~/.ssh/authorized_keys
qm set $VMID --ipconfig0 ip=dhcp
qm template $VMID
