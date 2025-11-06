#!/bin/bash
echo "Polygram Debian Image Builder"
SIZE="8G"
#FILENAME="polygram-debian-$(date +%Y_%m_%d-%k_%M).img"
FILENAME="polygram-debian.img"
ROOT_PASS="polygram"

[ "$UID" != "0" ] && exit 1
fallocate -l "$SIZE" "$FILENAME"
mkfs.ext4 "$FILENAME"
mount "$FILENAME" /mnt
debootstrap trixie /mnt http://deb.debian.org/debian || exit 1
echo "/dev/ubd0  /   ext4     discard,errors=remount-ro  0  1" | tee /mnt/etc/fstab
echo "/dev/ubd1  /lib/modules default                    0  0" | tee /mnt/etc/fstab
cp ../files/polygram-init-network /mnt/usr/bin
chmod u+x /mnt/usr/bin/polygram-init-network
cp ../files/polygram-network.service /mnt/etc/systemd/system
rm -rf /mnt/etc/hostname
cp /etc/hostname /mnt/etc/hostname
chroot /mnt /bin/sh -c "apt update && apt install neofetch -y --no-install-recommends && apt install dbus dbus-x11 curl wget iptables -y"
chroot /mnt /bin/sh -c "update-alternatives --set iptables /usr/sbin/iptables-legacy && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy"
chroot /mnt systemctl enable polygram-network
chroot /mnt /bin/sh -c "echo 'root:$ROOT_PASS' | chpasswd"
echo "polygram" >/mnt/etc/hostname
echo >>/mnt/etc/motd
echo "Polygram has usage limitations set by its creator." >>/mnt/etc/motd
echo "Violating these limitations may lead to consequences, including potential legal action." >>/mnt/etc/motd
umount /mnt

tar -czvf "$FILENAME.tar.gz" "$FILENAME"
