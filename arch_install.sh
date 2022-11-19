#!/bin/sh

#part1
clear

# Partitioning
lsblk
echo "Enter the drive, e.g. /dev/sda :" ; read -r drive ; cfdisk "$drive"
clear ; lsblk -f
echo "Enter the EFI system partition, e.g. /dev/sda1 :"
read -r efi_system_partition ; mkfs.fat -F 32 "$efi_system_partition"
echo "Enter the Linux swap partiton, e.g. /dev/sda2 :"
read -r swap_partition ; mkswap "$swap_partition"
echo "Enter Linux x86-64 root partition, e.g. /dev/sda3 :"
read -r root_partition ; mkfs.ext4 "$root_partition"

# Mounting
mount "$root_partition" /mnt
mount --mkdir "$efi_system_partition" /mnt/boot
swapon "$swap_partition"

iso=$(curl -4 ifconfig.co/country-iso)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-bak
reflector -a 48 -c "$iso" -f 5 -l 5 --sort rate --save /etc/pacman.d/mirrorlist \
  --download-timeout 60 --verbose

pacstrap /mnt base base-devel linux linux-firmware linux-headers neovim zsh
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' $(basename "$0") > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh ; exit

#part2
printf '\033c'
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime ; hwclock --systohc
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
pacman -Syu --noconfirm grub efibootmgr networkmanager dhcpcd intel-ucode \
  udiskie man-db man-pages git stow rsync usbutils

systemctl enable NetworkManager
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
echo "Enter username:" ; read -r username
useradd -m -G wheel -s /usr/bin/zsh "$username" ; passwd "$username"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "Installation finished, reboot now"
exit
