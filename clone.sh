#!/bin/bash

# Audio & Video
sudo pacman -S --noconfirm \
  pipewire pipewire-jack pipewire-alsa pipewire-pulse wireplumber qjackctl \
  mpv ffmpeg alsa-utils pulsemixer mpd mpc playerctl ncmpcpp obs-studio

# fonts
sudo pacman -S --noconfirm \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra libertinus-font \
  $(pacman -Ssq ttf- | grep -v 'ttf-nerd-fonts-symbols-mono\|ttf-linux-libertine\|ttf-nerd-fonts-symbols') \
  adobe-source-han-sans-jp-fonts adobe-source-han-serif-jp-fonts otf-ipafont

sudo pacman -S --noconfirm \
  xorg xorg-xinit libxrandr libx11 libxinerama xf86-video-ati \
  wget aria2 tmux zsh \
  zathura zathura-pdf-mupdf zathura-djvu texlive-most texlive-lang \
  libgccjit m17n-lib emacs \
  python python-pip imagemagick \
  go bat mediainfo ffmpegthumbnailer \
  p7zip zip unzip liblzf dosfstools ntfs-3g \
  shellcheck checkbashisms libnotify android-tools ifuse \
  flameshot redshift neofetch screenkey firefox \
  xwallpaper xdotool xclip xsel xbindkeys xcompmgr pass trash-cli \
  bash-completion fzy xdg-user-dirs npm ripgrep fd nnn slock

sudo npm install -g npm

# AUR
git clone --depth=1 https://aur.archlinux.org/paru-bin.git ~/.local/src/paru-bin \
  && cd ~/.local/src/paru-bin && makepkg -si --noconfirm && cd "$HOME" || exit

paru -S --useask --skipreview --noconfirm \
  libxft-bgra nsxiv mpdris2 nerd-fonts-jetbrains-mono ttf-monapo ttf-vlgothic

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
git clone --depth=1 https://github.com/GHQSTE/grabc ~/.local/src/suckless/rocks/grabc \
  && cd ~/.local/src/suckless/rocks/grabc && make && sudo make install

git clone --depth=1 https://github.com/jcs/xbanish.git ~/.local/src/suckless/rocks/xbanish \
  && cd ~/.local/src/suckless/rocks/xbanish && sudo make clean install

git clone --depth=1 https://github.com/pystardust/ani-cli ~/.local/src/ani-cli \
  && sudo cp ~/.local/src/ani-cli/ani-cli /usr/local/bin/ani-cli

cd "$HOME" || exit
# find ~/.local/src/. -maxdepth 1 ! -name 'suckless' -type d -exec rm -rf {} +

fc-cache -fv

# fzf - A command-line fuzzy finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

exit
