#!/bin/sh

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Vim
git clone --depth 1 https://github.com/vim/vim.git ~/.local/src/vim \
  && cd ~/.local/src/vim/src && make && sudo make install

exit
