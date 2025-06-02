#!/bin/bash
set -euo pipefail

DISK="/dev/sdb"
PART1="${DISK}1"
PART2="${DISK}2"
VG_NAME="vg_containerd"
LV_NAME="lv_containerd"
MOUNT_POINT="/var/lib/containerd"
FS_TYPE="ext4"

echo "Stopping containerd service..."
systemctl stop containerd || true

echo "Unmounting $MOUNT_POINT if mounted..."
if mountpoint -q "$MOUNT_POINT"; then
  umount "$MOUNT_POINT"
fi

echo "Cleaning contents of $MOUNT_POINT..."
if [ -d "$MOUNT_POINT" ]; then
  rm -rf "${MOUNT_POINT:?}/"*
else
  mkdir -p "$MOUNT_POINT"
fi

echo "Removing logical volume if exists..."
if lvdisplay "/dev/${VG_NAME}/${LV_NAME}" &>/dev/null; then
  lvremove -f "/dev/${VG_NAME}/${LV_NAME}"
fi

echo "Removing volume group if exists..."
if vgdisplay "$VG_NAME" &>/dev/null; then
  vgremove -f "$VG_NAME"
fi

echo "Removing physical volumes..."
for pv in "$PART1" "$PART2"; do
  if pvs --noheadings -o pv_name | grep -qw "$pv"; then
    # Remove pv from VG first if part of VG
    VG_OF_PV=$(pvs --noheadings -o vg_name --select pv_name="$pv" | xargs)
    if [ -n "$VG_OF_PV" ]; then
      vgchange -an "$VG_OF_PV"
      vgreduce "$VG_OF_PV" "$pv" || true
      vgchange -ay "$VG_OF_PV"
    fi
    pvremove --force --force "$pv"
  fi
done

echo "Installing parted package if missing..."
if ! command -v parted &>/dev/null; then
  apt-get update && apt-get install -y parted
fi

echo "Wiping existing partition table on $DISK..."
wipefs -a "$DISK"
dd if=/dev/zero of="$DISK" bs=512 count=2048 status=none || true
partprobe "$DISK"

echo "Creating new msdos partition table on $DISK..."
parted "$DISK" mklabel msdos --script

echo "Creating partitions..."
parted "$DISK" mkpart primary 1MiB 87GB --script
parted "$DISK" mkpart primary 87GB 100% --script
partprobe "$DISK"

echo "Creating physical volume on $PART1..."
pvcreate "$PART1"

echo "Creating volume group $VG_NAME with $PART1..."
vgcreate "$VG_NAME" "$PART1"

echo "Creating logical volume $LV_NAME using 100% free space..."
lvcreate -l 100%FREE -n "$LV_NAME" "$VG_NAME"

echo "Formatting logical volume $LV_NAME with $FS_TYPE filesystem..."
mkfs.$FS_TYPE -F "/dev/${VG_NAME}/${LV_NAME}"

echo "Ensuring mount point $MOUNT_POINT exists..."
mkdir -p "$MOUNT_POINT"

echo "Mounting logical volume..."
mount "/dev/${VG_NAME}/${LV_NAME}" "$MOUNT_POINT"

echo "Updating /etc/fstab..."
grep -q "^/dev/${VG_NAME}/${LV_NAME}" /etc/fstab || \
  echo "/dev/${VG_NAME}/${LV_NAME} $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab

echo "Starting containerd service..."
systemctl start containerd

echo "Setup completed successfully!"
