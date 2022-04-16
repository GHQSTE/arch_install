#!/bin/sh

printf '\033c'
cd "$HOME" || exit

# dirs
mkdir -p ~/.config ~/.local/state/bash ~/.local/state/zsh ~/.local/state/mpd \
  ~/.local/state/mpd/playlists ~/.local/state/ncmpcpp ~/.cache

# xdg-user-dirs
mkdir -p \
  ~/xdg-user-dirs/Downloads ~/xdg-user-dirs/Music ~/xdg-user-dirs/Pictures \
  ~/xdg-user-dirs/Videos ~/xdg-user-dirs/Documents ~/xdg-user-dirs/Desktop \
  ~/xdg-user-dirs/Templates ~/xdg-user-dirs/Public

rm -rf .bash_profile .bashrc .bash_login .bash_history .bash_logout

# dotfiles
git clone https://github.com/GHQSTE/dotfiles.git ~/.dotfiles \
  && cd .dotfiles/ && stow .

cd "$HOME" || exit

. ~/.bash_profile && . ~/.bashrc

rm -f .gitignore .bash_history

doas pacman -Syu --noconfirm xdg-user-dirs \
  npm ripgrep fd

doas npm install -g npm

. ~/.bash_profile && . ~/.bashrc

# AUR
git clone --depth=1 https://aur.archlinux.org/paru-bin.git ~/.local/src/paru-bin \
  && cd ~/.local/src/paru-bin && makepkg -si --noconfirm && cd "$HOME" || exit

paru -S --useask --skipreview --noconfirm \
  libxft-bgra nsxiv mpdris2 nerd-fonts-jetbrains-mono

# Install lf - terminal file manager on Unix (Go version >= 1.17):
env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest

# Installing python tools/programs
python3 -m pip install --user wheel
python3 -m pip install --user \
  ueberzug pywal dbus-python \
  mutagen brotli pycryptodomex websockets # yt-dlp dependencies for thumbnail-embedding.

# suckless software
git clone https://github.com/GHQSTE/dwm ~/.local/src/suckless/dwm \
  && cd ~/.local/src/suckless/dwm && doas make clean install \
  && make clean && rm -f config.h

git clone https://github.com/GHQSTE/st ~/.local/src/suckless/st \
  && cd ~/.local/src/suckless/st && doas make clean install \
  && make clean && rm -f config.h

# suckless tools
git clone https://github.com/GHQSTE/dmenu ~/.local/src/suckless/dmenu \
  && cd ~/.local/src/suckless/dmenu && doas make clean install \
  && make clean && rm -f config.h

git clone https://github.com/GHQSTE/slock ~/.local/src/suckless/slock \
  && cd ~/.local/src/suckless/slock && doas make clean install \
  && make clean && rm -f config.h

# Stuff that rocks
git clone --depth=1 https://github.com/GHQSTE/grabc ~/.local/src/suckless/rocks/grabc \
  && cd ~/.local/src/suckless/rocks/grabc && make && doas make install

git clone --depth=1 https://github.com/GHQSTE/xbanish ~/.local/src/suckless/rocks/xbanish \
  && cd ~/.local/src/suckless/rocks/xbanish && doas make clean install

git clone --depth=1 https://github.com/pystardust/ani-cli ~/.local/src/ani-cli \
  && doas cp ~/.local/src/ani-cli/ani-cli /usr/local/bin/ani-cli

cd "$HOME" || exit
# find ~/.local/src/. -maxdepth 1 ! -name 'suckless' -type d -exec rm -rf {} +

fc-cache -fv

# fzf - A command-line fuzzy finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

exit
