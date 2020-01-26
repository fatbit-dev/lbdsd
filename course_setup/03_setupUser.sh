#!/bin/bash

# Useful functions
error() {
  echo -e "\e[31m $@ \e[0m"
}

msg() {
    echo ''
    echo -e "\e[36m $@ \e[0m"
    echo ''
}


echo ''
echo '>>> ==============================='
echo '>>>             LBDSO              '
echo '>>>   ---------------------------  '
echo '>>>    Convenience User Settings   '
echo '>>>              Setup             '
echo '>>> ==============================='
echo ''

if [[ $(id -u) -eq 0 ]]; then
    echo ''
    error ">>> Please, don't run as root."
    echo ''
    exit 1
fi

mkdir "$HOME/bin"
cd "$HOME/bin"

msg '>>> Getting git-completion for bash...'
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
git clone https://github.com/magicmonty/bash-git-prompt.git ~/bin/.bash-git-prompt --depth=1

msg '>>> Setting-up ~/.bashrc...'
cat >>"~/.bashrc" <<'BASHRC' 

# lbdsd Customizations

# Life is colors :)
export PS1="\[\033[01;32m\][dev] \[\033[01;37m\]\u\[\033[01;34m\]@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ "
#export LS_COLORS="di=36:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31:mi=0:ex=35"

# List files
alias ls='ls --color=auto --time-style=long-iso'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'

# Clear the screen
alias c='clear'
alias cls='clear && ls'

# Up 'n' folders
alias cd..='cd ..'
alias CD..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'

# Colors in grep
alias grep='grep --color=auto'

# Some useful functions
ff () { find / -name "*$@*" ; }
ft () { grep -r "$@" ./ --color ; }

# Some helper aliases for PM2
# pmi () { pm2 info "$@" ; }
# pml () { pm2 log --lines=100 ; }

# Disable mail messages
unset MAILCHECK

# Set vim terminal to 256 colors.
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
    export TERM='xterm-256color'
else
    export TERM='xterm-color'
fi

export PATH=$PATH:$HOME/bin

# lbdsd: Enable git completion
. ~/bin/git-completion.bash

# lbdsd: Enable bash-git-prompt
if [ -f "$HOME/bin/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/bin/.bash-git-prompt/gitprompt.sh
fi

# lbdsd: Git Aliases and Functions
# alias ga='git add'
# alias gaa='git add .'
# alias gaaa='git add --all'
# alias gau='git add --update'
# alias gb='git branch'
# alias gbd='git branch --delete '
# alias gc='git commit'
# alias gcm='git commit --message'
# alias gcma='git commit -am'
# alias gcf='git commit --fixup'
# alias gco='git checkout'
# alias gcob='git checkout -b'
# alias gcom='git checkout master'
# alias gcos='git checkout staging'
# alias gcod='git checkout develop'
# alias gd='git diff'
# alias gda='git diff HEAD'
# alias gi='git init'
# alias glg='git log --graph --oneline --decorate --all'
# alias gld='git log --pretty=format:"%h %ad %s" --date=short --all'
# alias gm='git merge --no-ff'
# alias gma='git merge --abort'
# alias gmc='git merge --continue'
# alias gp='git pull'
# alias gpr='git pull --rebase'
# alias gr='git rebase'
# alias gs='git status'
# alias gss='git status --short'
# alias gst='git stash'
alias gst='git status'
# alias gsta='git stash apply'
# alias gstd='git stash drop'
# alias gstl='git stash list'
# alias gstp='git stash pop'
# alias gsts='git stash save'

# lbdsd: Git log find by commit message
function glf() { git log --all --grep="$1"; }

BASHRC

msg '>>> Setting-up vim and ~/.vimrc...'
mkdir ~/.vim

# Install some color schemes for vim
git clone https://github.com/flazz/vim-colorschemes.git ~/.vim

# Setup .vimrc
cat >>~/.vimrc <<'VIMRC'
" Configure TAB behaviour
filetype plugin indent on
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

set hlsearch
set ruler
set mouse=nc
set pastetoggle=<F2>
set foldmethod=marker
set number

" Coloring vim
syntax on
set t_Co=256
set background=dark
"colorscheme desert
colorscheme molokai

VIMRC

msg '>>> Installing some color themes for Geany...'
mkdir "$HOME/bin/beauty"
cd "$HOME/bin/beauty"
git clone https://github.com/codebrainz/geany-themes.git
cd geany-themes
./install.sh

msg '>>> Configuring git user...'
git config --global user.name "gitUser"
git config --global user.email "someUser@someHost.com"

msg '>>> Done!'
