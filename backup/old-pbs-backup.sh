export PBS_LOG=error
export PBS_REPOSITORY=pbs.lan:diskstation
export PBS_PASSWORD=Relic2-Jam-Unlocking
proxmox-backup-client backup miniserver.pxar:/ \
	-ns non-proxmox \
    --exclude /proc \
    --exclude /srv \
    --exclude /sys \
    --exclude /tmp \
	--exclude /run \
	--exclude /backup \
	--exclude /media \
	--exclude /dev \
	--exclude /mnt \
	--exclude /snap \
	--exclude /var/lib/docker/overlay2

