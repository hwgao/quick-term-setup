#!/bin/bash

check_cmd() {
  command -v "$1" &>/dev/null
}

# On MacOS install brew first
if [ "$(uname)" == "Darwin" ]; then
  check_cmd brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check_cmd code || brew install nvim tmux fzf ripgrep fd mc tig tree cmake git go node visual-studio-code
else
  apt install tmux fzf ripgrep fd-find mc tig tree cmake git curl build-essential
  snap install nvim go node
  check_cmd xinit || snap install code
fi

if [ "$SHELL" == "/bin/zsh" ]; then
  test -d "${HOME}/.oh-my-zsh" || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Configure tmux
cat <<EOF > "${HOME}"/.tmux.conf
set -g mouse on
set -g base-index 1
set -g status-keys vi
set -g mode-keys vi

setw -g window-status-current-style "fg=blue bg=white bold"
setw -g status-style "fg=white bg=blue"
EOF

# Configure nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

cat <<EOF > "${HOME}"/.config/nvim/init.vim
if exists('g:vscode')
  " vscode extension
  nnoremap <silent> <space>l :<C-u>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
  nnoremap <silent> <space>o :<C-u>call VSCodeNotify('workbench.action.toggleZenMode')<CR>
  nnoremap <silent> <space>b :<C-u>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<CR>
  nnoremap <silent> <space>s :<C-u>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>') })<CR>
  nnoremap <silent> gr :<C-u>call VSCodeNotify('references-view.find')<CR>
else
  " ordinary neovim
  set runtimepath^=~/.vim/bundle runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  " Specify a directory for plugins
  call plug#begin('~/.vim/bundle')
  call plug#end()
endif

set ignorecase                             " Search case insensitive...
set smartcase                              " ... but not it begins with upper case
set clipboard=unnamedplus
nnoremap <Space><Space> :nohls<CR>
EOF
