#!/bin/bash

# AUR
git clone --depth 1 https://github.com/Jguer/yay.git ~/.local/src/yay \
  && cd ~/.local/src/yay && makepkg -si --noconfirm && cd "$HOME" || exit

# fonts
yay -S --useask --noconfirm \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra libertinus-font \
  nerd-fonts-jetbrains-mono

# Audio & Video
yay -S --noconfirm \
  pipewire-jack pipewire-alsa pipewire-pulse qjackctl wireplumber \
  mpv ffmpeg alsa-utils pulsemixer mpd mpc playerctl ncmpcpp obs-studio

yay -S --noconfirm \
  xorg xorg-xinit xf86-video-ati \
  zathura zathura-pdf-mupdf zathura-djvu texlive-most texlive-lang \
  wget aria2 tmux \
  python python-pip imagemagick \
  bat mediainfo ffmpegthumbnailer \
  zip unzip dosfstools ntfs-3g \
  shellcheck checkbashisms libnotify android-tools \
  flameshot redshift neofetch screenkey firefox \
  xwallpaper xdotool xclip xsel xbindkeys xcompmgr pass trash-cli \
  bash-completion xdg-user-dirs npm ripgrep fd nnn slock

sudo npm install -g npm

yay -S --useask --noconfirm \
  nsxiv mpdris2

# Installing python tools/programs
python3 -m pip install -U --user wheel
python3 -m pip install -U --user \
  ueberzug pywal dbus-python yt-dlp \
  mutagen brotli pycryptodomex websockets # yt-dlp dependencies for thumbnail-embedding.

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
