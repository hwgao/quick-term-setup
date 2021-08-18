#!/bin/bash

check_cmd() {
  command -v "$1" &>/dev/null
}

# On MacOS install brew first
if [ "$(uname)" == "Darwin" ]; then
  check_cmd brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check_cmd code || brew install nvim tmux fzf ripgrep fd mc tig tree cmake git go node visual-studio-code
else
  if check_cmd apt; then
    check_cmd tmux || sudo apt update
    check_cmd tmux || sudo apt install -y tmux fzf ripgrep fd-find mc tig tree cmake git curl build-essential
  else
    echo "Error: No apt command"
  fi
  if check_cmd snap; then
    sudo snap install nvim --candidate --classic
    sudo snap install go --classic
    sudo snap install node --channel 14/stable --classic
    check_cmd xinit && sudo snap install code --classic
  else
    echo "Error: No snap command"
  fi
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
set -g renumber-windows on

# Smart pane switching with awareness of Vim splits.
# # See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-h if-shell "\$is_vim" "send-keys C-h"  "select-pane -L"
bind -n C-j if-shell "\$is_vim" "send-keys C-j"  "select-pane -D"
bind -n C-k if-shell "\$is_vim" "send-keys C-k"  "select-pane -U"
bind -n C-l if-shell "\$is_vim" "send-keys C-l"  "select-pane -R"

# create new window with the current directory
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Clear screen
bind C-l send-keys 'C-l'

# Theme
setw -g window-status-current-style "fg=white bg=color32 bold"
setw -g status-style "fg=white bg=color234"
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
  Plug 'vim-airline/vim-airline'
  Plug 'christoomey/vim-tmux-navigator'
  call plug#end()
endif

set ignorecase                             " Search case insensitive...
set smartcase                              " ... but not it begins with upper case
set clipboard=unnamedplus
nnoremap <Space><Space> :nohls<CR>
EOF

cat <<EOF > "${HOME}"/.tigrc
# Push local changes to origin
bind status P !git push origin
bind main P !git push origin

# Delete file under cursor
bind status D !?rm -rf "%(file)"

# Checkout the original version
bind status O !?git checkout -- "%(file)"

color graph-commit green default
EOF
