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

rm -f .gitignore

doas pacman -Syu --noconfirm xdg-user-dirs \
  npm ripgrep fd

doas npm install -g npm

exit
