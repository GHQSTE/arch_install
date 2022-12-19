#!/bin/bash

printf '\033c'
cd "$HOME" || exit

rm -rf .bash_profile .bashrc .bash_login .bash_history .bash_logout \
  .cache/ .viminfo

# dirs
mkdir -p ~/.config ~/.local/state/bash ~/.local/state/zsh ~/.local/state/mpd \
  ~/.local/state/mpd/playlists ~/.local/state/ncmpcpp ~/.cache ~/.vim/undo

# dotfiles
git clone https://github.com/GHQSTE/dotfiles.git ~/.dotfiles \
  && cd .dotfiles/ && stow .

cd "$HOME" || exit

rm -f .gitignore .bash_history

source ~/.zshenv ; source ~/.zprofile

# AUR
git clone --depth 1 https://aur.archlinux.org/yay.git ~/.local/src/yay \
  && cd ~/.local/src/yay && makepkg -si --noconfirm && cd "$HOME" || exit

# fonts
yay -S --useask --noconfirm \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra libertinus-font \
  nerd-fonts-jetbrains-mono

yay -S --useask --noconfirm \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
  mpv ffmpeg alsa-utils pulsemixer mpd playerctl ncmpcpp obs-studio

yay -S --useask --noconfirm \
  xorg xorg-xinit \
  zathura zathura-pdf-mupdf zathura-djvu \
  wget aria2 tmux \
  python python-pip imagemagick \
  zip unzip dosfstools exfatprogs ntfs-3g \
  shellcheck checkbashisms libnotify android-tools \
  flameshot maim redshift neofetch screenkey firefox \
  xwallpaper xdotool xclip xsel xbindkeys xcompmgr pass trash-cli \
  bash-completion xdg-user-dirs npm ripgrep fd nnn slock discord nsxiv

xdg-user-dirs-update
sudo npm install -g npm

# Installing python tools/programs
python3 -m pip install -U --user wheel
python3 -m pip install -U --user pywal dbus-python yt-dlp

# suckless software
git clone --depth 1 https://github.com/GHQSTE/dwm ~/.local/src/suckless/dwm \
  && cd ~/.local/src/suckless/dwm && sudo make clean install \
  && make clean && rm -f config.h

git clone --depth 1 https://github.com/GHQSTE/st ~/.local/src/suckless/st \
  && cd ~/.local/src/suckless/st && sudo make clean install \
  && make clean && rm -f config.h

# suckless tools
git clone --depth 1 https://github.com/GHQSTE/dmenu ~/.local/src/suckless/dmenu \
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
fc-cache -fv
sh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.sh)

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

exit
