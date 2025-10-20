#!/bin/env bash

# This script is used to backup from Proxmox Virtual Environment (PVE) to the Proxmox Backup Server (PBS).
# Must have a valid API token for the user on the Proxmox Backup Server (PBS) to run this script.

# ==================== Define variables (Edit Below) ==================== #
DRY_RUN=false    # true/false, for testing purposes true (only logs will be generated), for production false (actual run)
CLIENT_HOSTNAME="$(hostname)"
PBS_USER="root"
PBS_NAMESPACE="non-proxmox" # Namespace should be available in PBS alredy
BACKUP_PATH="/"  # use full path and no spaces in the path, eg "/home/user"

# On Proxmox Backup Server UI, PBS>Datastore>"Show Connection Information"
PBS_SERVER_IP="pbs.lan"
PBS_SERVER_PORT="8007"  # Default port is 8007
PBS_DATASTORE="diskstation"
PBS_FINGERPRINT="e5:c8:d5:ef:79:6c:c3:bd:9f:fa:42:7a:3e:a9:ac:b4:f1:b3:41:9b:01:3f:ea:b0:ec:81:d2:e9:1b:51:9c:87"
PATH_FOR_LOGS="/var/log/proxmox-backup"
DAYS_KEEP_LOGS="30"
PBS_EXCLUDE="--exclude /proc \
    --exclude /srv \
    --exclude /sys \
    --exclude /tmp \
    --exclude /run \
    --exclude /backup \
    --exclude /media \
    --exclude /dev \
    --exclude /mnt \
    --exclude /snap \
    --exclude /boot/efi \
    --exclude /boot/firmware \
    --exclude /store \
    --exclude /var/lib/docker/overlay2"

# ==================== End of Define variables ==================== #

# ==================== Start of Script (Do not Edit Below) ==================== #
# ------------------- export PBS Environment Secrets: ------------------- #
export PBS_FINGERPRINT=${PBS_FINGERPRINT}
export PBS_REPOSITORY=${PBS_USER}@pam@${PBS_SERVER_IP}:${PBS_SERVER_PORT}:${PBS_DATASTORE}
export PBS_PASSWORD=Relic2-Jam-Unlocking

# Initialize the backup command
PBS_BACKUP_COMMAND="proxmox-backup-client backup ${CLIENT_HOSTNAME}.pxar:${BACKUP_PATH} --ns ${PBS_NAMESPACE} ${PBS_EXCLUDE}"

# get the current date and time and store it
date=$(date)
# Get the current time zone in "Region/City" format
current_time_zone=$(timedatectl show --property=Timezone --value)
# get the current date and time in IST and store it, to use as filename for the log file
date_Filename=$(TZ=${current_time_zone} date +'%Y-%m-%d_%I-%M-%S-%p')
# get the current date and time in IST and store it, for display in terminal and printing to the log file
start_date_formatted=$(TZ=${current_time_zone} date +'%Y-%m-%d | %I:%M:%S %p')

# ------------------- Set paths ------------------- #
# format the variable PBS_NAMESPACE to replace "/" or any other symbols with "-"
PBS_NAMESPACE_FORMATED=$(echo $PBS_NAMESPACE | sed 's/[/\|]/-/g')
# create a variable for path to the log file
log_file_path="${PATH_FOR_LOGS}/${date_Filename}_${PBS_NAMESPACE_FORMATED}.log"
# Redirect stdout and stderr to tee
exec > >(tee -a "$log_file_path") 2>&1

# ------------------- Functions ------------------- #
# create a separator function to print a separator line, # Usage: log_separator
log_separator() {
    echo "========================================"
    echo ""
}
# create a separator function to print a separator line, # Usage: single_separator
single_separator() {
    echo "========================================"
}
# create a smaller separator function to print a smaller separator line, # Usage: small_separator
small_separator() {
    echo "--------------------"
}

# print starting date and time
log_separator
echo "Starting Update at: $start_date_formatted"
log_separator

# ------------------- Start of backup script ------------------- #
echo
# print stuff:
echo "Backup Source             -    [$CLIENT_HOSTNAME]"
echo "Backup Directory          -    [$BACKUP_PATH]"
small_separator
echo "Backup Destination        -    [Proxmox Backup Server] @ [$PBS_SERVER_IP:$PBS_SERVER_PORT]"
echo "Destination Datastore     -    [$PBS_DATASTORE] @ [$PBS_SERVER_IP:$PBS_SERVER_PORT]"
small_separator
echo "Repository                -    [${PBS_USER}@pbs!${PBS_TOKEN_NAME}@${PBS_SERVER_IP}:${PBS_SERVER_PORT}:${PBS_DATASTORE}]"
echo "Datastore                 -    [$PBS_DATASTORE]"
echo "Namespace                 -    [$PBS_NAMESPACE]"
echo "Environment Variables     -    [PBS_PASSWORD_FILE], [PBS_FINGERPRINT], [PBS_REPOSITORY]"
small_separator
echo "Directories Excluded      -    [mnt/**], [var/lib/vz**], [**tmp**], [/etc/pve/**] and all mounted drives by Default."
echo "Force Included            -    [$FORCE_INCLUDE_PATH]"
echo "Ignore List               -    [.pxarexclude] #Edit this file to exclude patterns."
# echo "Include in .pxarexclude   -    [nothing]"
small_separator
echo "Skipped mount points      -    [dev], [proc], [run], [sys], [var/lib/lxcfs] by Default."
echo ""
single_separator
echo "Running the following command:"
small_separator
echo "${PBS_BACKUP_COMMAND}"
log_separator
echo "running backup, please wait..."

# if DRY_RUN is true, run ${PBS_BACKUP_COMMAND} --dry-run, else run ${PBS_BACKUP_COMMAND}, echo the command before running
if [ "$DRY_RUN" = true ]; then
    
    echo "Dry Running: "
    # Countdown from 3 to 1
    for i in {3..1}; do
        echo -ne " --dry-run -> $i\r"
        sleep 1
        echo -ne "                \r"
    done
    echo "${PBS_BACKUP_COMMAND} --dry-run"
    ${PBS_BACKUP_COMMAND} --dry-run
elif [ "$DRY_RUN" = false ]; then
    echo "running backup, please wait..."
    # Countdown from 3 to 1
    for i in {3..1}; do
        echo -ne " Starting -> $i\r"
        sleep 1
        echo -ne "               \r"
    done
    echo "${PBS_BACKUP_COMMAND}"
    ${PBS_BACKUP_COMMAND}
else
    echo "Invalid value for DRY_RUN. Exiting."
    # Countdown from 3 to 1
    for i in {3..0}; do
        echo -ne " Exiting, -> $i\r"
        sleep 1
        echo -ne "              \r"
    done
    exit 1
fi

sleep 2.0s
echo ""

single_separator
echo "Started Update at: $start_date_formatted"
single_separator
# convert the date to IST with format "YYYY-MM-DD | I:MM:SS p" and add it to the log file
finish_date_formatted=$(TZ=${current_time_zone} date +'%Y-%m-%d | %I:%M:%S %p')
echo "Finished Update at: $finish_date_formatted"
single_separator

# since "|" creates issues in the date command, we need to remove it for the math to work
start_date_for_math=$(echo $start_date_formatted | sed 's/| //')
finish_date_for_math=$(echo $finish_date_formatted | sed 's/| //')
# total time taken in the format "H:M:S"
echo "Total time taken: $(date -d @$(( $(date -d "$finish_date_for_math" +%s) - $(date -d "$start_date_for_math" +%s) )) -u +%H:%M:%S)"
log_separator

# print "Please check the log file for more details" to the console along with the path to the log file
echo "Please check the log file for more details:"
small_separator
echo "$log_file_path"
log_separator

# delete the log files older than "DAYS_KEEP_LOGS" days and print the files that are being deleted
log_file_dir=$(dirname "$log_file_path")/
echo "Log files older than "DAYS_KEEP_LOGS" days, under '$log_file_dir' that were deleted:"
small_separator
find $log_file_dir -type f -mtime +"${DAYS_KEEP_LOGS}" -exec sh -c 'echo "$1"; rm -f "$1"' _ {} \;
small_separator

# exit the script
echo ""
echo "exiting"
echo ""
# clear the variables and clear the export variables to avoid any conflicts with other scripts or commands that may use the same variables
unset PBS_PASSWORD_FILE PBS_FINGERPRINT PBS_REPOSITORY date_Filename date start_date_formatted finish_date_formatted start_date_for_math finish_date_for_math log_file_path log_file_dir log_separator single_separator small_separator FORCE_INCLUDE_PATH
exit 0



