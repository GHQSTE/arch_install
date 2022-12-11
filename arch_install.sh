#!/bin/sh

#part1
clear
lsblk
echo "Enter the drive, e.g. /dev/sda :"
read -r drive

echo -n mem > /sys/power/state
hdparm --user-master u --security-set-pass p "$drive"
hdparm --user-master u --security-erase-enhanced p "$drive"

cfdisk "$drive"
echo "Enter Linux x86-64 root partition, e.g. /dev/sda3 :"
read -r root_partition ; mkfs.ext4 "$root_partition"
echo "Enter the Linux swap partiton, e.g. /dev/sda2 :"
read -r swap_partition ; mkswap "$swap_partition"
echo "Enter the EFI system partition, e.g. /dev/sda1 :"
read -r efi_system_partition ; mkfs.fat -F 32 "$efi_system_partition"

mount "$root_partition" /mnt
mount --mkdir "$efi_system_partition" /mnt/boot
swapon "$swap_partition"

echo "Server = http://mirror.xeonbd.com/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
pacstrap -K /mnt base base-devel linux-zen linux-firmware intel-ucode xf86-video-ati man-db man-pages
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' $(basename "$0") > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen ; echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Enter hostname: " ; read -r hostname
echo "$hostname" > /etc/hostname
{
echo "127.0.0.1       localhost"
echo "::1             localhost"
echo "127.0.1.1       $hostname"
} >> /etc/hosts
echo "Enter root/superuser password:" ; passwd

pacman -S --noconfirm \
  neovim git stow zsh rsync \
  grub efibootmgr networkmanager dhcpcd

systemctl enable NetworkManager
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
echo "Enter username:" ; read -r username
useradd -m -G wheel -s /bin/bash "$username" ; passwd "$username"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "Pre-Installation Finished, Reboot Now"
exit
