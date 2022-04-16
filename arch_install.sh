#!/bin/sh

#part1
printf '\033c'
setfont ter-v22b
iso=$(curl -4 ifconfig.co/country-iso)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-bak
reflector -a 48 -c "$iso" -f 5 -l 5 --sort rate --save /etc/pacman.d/mirrorlist \
  --download-timeout 60 --verbose

timedatectl set-ntp true
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Partitioning
clear ; lsblk
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

pacstrap /mnt base base-devel linux linux-firmware linux-headers
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' $(basename "$0") > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh ; exit

#part2
printf '\033c'
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#color/color/' /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime ; hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#bn_BD UTF-8/bn_BD UTF-8/' /etc/locale.gen
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
  udiskie terminus-font
systemctl enable NetworkManager

# Audio & Video
pacman -Syu --noconfirm \
  pipewire pipewire-pulse pipewire-jack wireplumber \
  mpv ffmpeg alsa-utils mpd mpc playerctl ncmpcpp obs-studio

pacman -Syu --noconfirm \
  xorg xorg-xinit libxrandr libx11 libxinerama fontconfig xf86-video-ati \
  man-db man-pages neovim git stow rsync wget aria2 tmux opendoas dash zsh\
  noto-fonts noto-fonts-emoji noto-fonts-cjk libertinus-font \
  $(pacman -Ssq ttf- | grep -v 'ttf-nerd-fonts-symbols-mono\|ttf-linux-libertine') \
  adobe-source-han-sans-jp-fonts adobe-source-han-serif-jp-fonts otf-ipafont \
  zathura zathura-pdf-mupdf zathura-djvu \
  libgccjit m17n-lib \
  python python-pip imagemagick \
  go bat mediainfo ffmpegthumbnailer \
  p7zip zip unzip liblzf dosfstools ntfs-3g \
  shellcheck checkbashisms dunst libnotify android-tools ifuse \
  flameshot yt-dlp redshift neofetch screenkey firefox \
  xwallpaper xdotool xclip xsel xbindkeys xcompmgr pass trash-cli \
  bash-completion lazygit fzy

# setup dash to be symlinked to sh instead of bash.
ln -sfT dash /usr/bin/sh
{
echo "[Trigger]"
echo "Type = Package"
echo "Operation = Install"
echo "Operation = Upgrade"
echo "Target = bash"
echo
echo "[Action]"
echo "Description = Re-pointing /bin/sh symlink to dash..."
echo "When = PostTransaction"
echo "Exec = /usr/bin/ln -sfT dash /usr/bin/sh"
echo "Depends = dash"
} > /usr/share/libalpm/hooks/dash.hook

echo "permit nopass :wheel" > /etc/doas.conf
chown -c root:root /etc/doas.conf ; chmod -c 0400 /etc/doas.conf
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

echo "FONT=ter-v22b" > /etc/vconsole.conf
echo "Enter username:" ; read -r username
useradd -m -G wheel -s /bin/bash "$username" ; passwd "$username"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "Installation finished, reboot now"
exit
