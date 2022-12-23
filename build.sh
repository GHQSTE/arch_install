#!/bin/sh

# Vim
git clone --depth 1 https://github.com/vim/vim.git ~/.local/src/vim \
  && cd ~/.local/src/vim/src && make && sudo make install

exit
