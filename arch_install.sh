#!/bin/sh

#part1
clear
lsblk
echo "Enter the drive, e.g. /dev/sda :"
read -r drive ; cfdisk "$drive"
echo "Enter Linux x86-64 root partition, e.g. /dev/sda3 :"
read -r root_partition ; mkfs.ext4 "$root_partition"
echo "Enter the Linux swap partiton, e.g. /dev/sda2 :"
read -r swap_partition ; mkswap "$swap_partition"
echo "Enter the EFI system partition, e.g. /dev/sda1 :"
read -r efi_system_partition ; mkfs.fat -F 32 "$efi_system_partition"

mount "$root_partition" /mnt
mount --mkdir "$efi_system_partition" /mnt/boot
swapon "$swap_partition"

iso=$(curl -4 ifconfig.co/country-iso)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-bak
reflector -a 48 -c "$iso" -f 5 -l 5 --sort rate --save /etc/pacman.d/mirrorlist \
  --download-timeout 60 --verbose

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers intel-ucode xf86-video-ati
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
  neovim git stow zsh rsync man-db man-pages \
  grub efibootmgr networkmanager dhcpcd

systemctl enable NetworkManager
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
echo "Enter username:" ; read -r username
useradd -m -G wheel -s /usr/bin/zsh "$username" ; passwd "$username"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "Pre-Installation Finished, Reboot Now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit

#part3
printf '\033c'
cd "$HOME" || exit

rm -rf .bash_profile .bashrc .bash_login .bash_history .bash_logout \
  .cache/ .viminfo

# dirs
mkdir -p ~/.config ~/.local/state/bash ~/.local/state/zsh ~/.local/state/mpd \
  ~/.local/state/mpd/playlists ~/.local/state/ncmpcpp ~/.cache ~/.vim/undo

# xdg-user-dirs
mkdir -p \
  ~/xdg-user-dirs/Downloads ~/xdg-user-dirs/Music ~/xdg-user-dirs/Pictures \
  ~/xdg-user-dirs/Videos ~/xdg-user-dirs/Documents ~/xdg-user-dirs/Desktop \
  ~/xdg-user-dirs/Templates ~/xdg-user-dirs/Public

# dotfiles
git clone https://github.com/GHQSTE/dotfiles.git ~/.dotfiles \
  && cd .dotfiles/ && stow .

cd "$HOME" || exit

rm -f .gitignore .bash_history

# AUR
git clone https://aur.archlinux.org/yay.git ~/.local/src/yay \
  && cd ~/.local/src/yay && makepkg -si --noconfirm && cd "$HOME" || exit

# fonts
yay -S --useask --noconfirm \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra libertinus-font \
  nerd-fonts-jetbrains-mono

# Audio & Video
yay -S --useask --noconfirm \
  pipewire-jack pipewire-alsa pipewire-pulse qjackctl wireplumber \
  mpv ffmpeg alsa-utils pulsemixer mpd mpdris2 playerctl ncmpcpp obs-studio

yay -S --noconfirm \
  xorg xorg-xinit \
  zathura zathura-pdf-mupdf zathura-djvu \
  wget aria2 tmux \
  python python-pip imagemagick \
  bat mediainfo ffmpegthumbnailer \
  zip unzip dosfstools exfatprogs ntfs-3g udiskie \
  shellcheck checkbashisms libnotify android-tools \
  flameshot redshift neofetch screenkey firefox \
  xwallpaper xdotool xclip xsel xbindkeys xcompmgr pass trash-cli \
  bash-completion xdg-user-dirs npm ripgrep fd nnn slock discord nsxiv

sudo npm install -g npm

# Installing python tools/programs
python3 -m pip install -U --user wheel
python3 -m pip install -U --user pywal dbus-python yt-dlp

# suckless software
git clone https://github.com/GHQSTE/dwm ~/.local/src/suckless/dwm \
  && cd ~/.local/src/suckless/dwm && sudo make clean install \
  && make clean && rm -f config.h

git clone https://github.com/GHQSTE/st ~/.local/src/suckless/st \
  && cd ~/.local/src/suckless/st && sudo make clean install \
  && make clean && rm -f config.h

# suckless tools
git clone https://github.com/GHQSTE/dmenu ~/.local/src/suckless/dmenu \
  && cd ~/.local/src/suckless/dmenu && sudo make clean install \
  && make clean && rm -f config.h

# Stuff that rocks
git clone --depth 1 https://github.com/GHQSTE/grabc ~/.local/src/suckless/rocks/grabc \
  && cd ~/.local/src/suckless/rocks/grabc && make && sudo make install

git clone --depth 1 https://github.com/jcs/xbanish.git ~/.local/src/suckless/rocks/xbanish \
  && cd ~/.local/src/suckless/rocks/xbanish && sudo make clean install

git clone --depth 1 https://github.com/pystardust/ani-cli ~/.local/src/ani-cli \
  && sudo cp ~/.local/src/ani-cli/ani-cli /usr/local/bin/ani-cli

cd "$HOME" || exit
# find ~/.local/src/. -maxdepth 1 ! -name 'suckless' -type d -exec rm -rf {} +

fc-cache -fv

sh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.sh)

exit
