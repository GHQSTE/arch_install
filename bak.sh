#!/bin/bash

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
printf '%s\n' "Enabling parallel downloads and updating keyring"
sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 10/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode xf86-video-ati man-db man-pages
genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' $(basename "$0") > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
rm -rf /mnt/arch_install2.sh

exit

#part2
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
sed -i 's/^ParallelDownloads = 10/&\nILoveCandy/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

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
useradd -m -G wheel -s /usr/bin/zsh "$username" ; passwd "$username"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
rm -rf $ai3_path
printf '%s\n' "Pre-Installation Finish Reboot now"
exit

#part3
cd ~

# dirs
mkdir -p ~/.config ~/.local/state/bash ~/.local/state/zsh ~/.local/state/mpd \
  ~/.local/state/mpd/playlists ~/.local/state/ncmpcpp ~/.cache ~/.vim/undo

# dotfiles
git clone https://github.com/GHQSTE/dotfiles.git ~/.dotfiles \
  && cd .dotfiles/ && stow .

cd ~
rm -f .gitignore

# yay - Yet Another Yogurt - An AUR Helper Written in Go
git clone --depth 1 https://aur.archlinux.org/yay.git ~/.local/src/yay \
  && cd ~/.local/src/yay && makepkg -si --noconfirm && cd ~

# fonts
yay -S \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
  nerd-fonts-jetbrains-mono

yay -S \
  ffmpeg pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
  mpv mpd ncmpcpp pamixer playerctl alsa-utils pulsemixer obs-studio

## dependencies to build wlroots n river
#yay -S --devel \
#  zig wayland wayland-protocols xorg-xwayland seatd xcb-util-errors libxkbcommon \
#  libevdev pixman scdoc
#
#git clone https://gitlab.freedesktop.org/wlroots/wlroots.git ~/.local/src/wlroots
#cd ~/.local/src/wlroots
#git switch 0.16
#meson setup build/
#ninja -C build/
#sudo ninja -C build/ install
#
#git clone https://github.com/riverwm/river.git ~/.local/src/river
#cd ~/.local/src/river
#git submodule update --init
#zig build -Drelease-safe --prefix ~/.local install

# riverwm
yay -S --useask --noconfirm \
  river-git polkit polkit-dumb-agent-git foot wlr-randr bemenu-wayland \
  imv mako grim swww gifsicle

yay -S --useask --noconfirm \
  zathura zathura-pdf-mupdf zathura-djvu \
  wget aria2 tmux \
  python python-pip imagemagick wayshot-bin wl-clipboard slurp \
  zip unzip dosfstools exfatprogs ntfs-3g \
  shellcheck checkbashisms libnotify android-tools \
  redshift neofetch firefox \
  pass trash-cli exa \
  bash-completion xdg-user-dirs npm ripgrep fd nnn discord nsxiv

xdg-user-dirs-update

sudo npm install -g npm

# Installing python tools/programs
python3 -m pip install -U --user wheel
python3 -m pip install -U --user pywal dbus-python yt-dlp

cd ~
fc-cache -fv
sh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.sh)

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

exit
