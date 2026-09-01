# Shared interactive shell configuration for Arch Linux and macOS.

if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1 && [[ "$TERM" != "xterm-256color" ]]; then
    fastfetch
fi

export PATH="$HOME/.local/bin:$PATH"

if [[ "$(uname -s)" == "Darwin" ]] && [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/llvm/bin:/opt/homebrew/opt/ssh-copy-id/bin:$PATH"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "${ZINIT_HOME:h}"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git
zinit snippet OMZP::sudo
if [[ "$(uname -s)" == "Linux" ]]; then
    zinit snippet OMZP::archlinux
fi

autoload -Uz compinit && compinit

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTSIZE=100000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=100000
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups
setopt hist_save_no_dups hist_ignore_dups hist_find_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
if [[ -n "${LS_COLORS:-}" ]]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls $realpath'

alias ll='ls -lAtr'
alias vim='nvim'
alias c='clear'
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'

if [[ "$(uname -s)" == "Darwin" ]]; then
    alias ls='ls -G'
    alias lock='macos-system-action lock'
    alias vpn='run-openvpn-split'
else
    alias ls='ls --color=auto'
    alias lock='hyprlock'
    alias vpn='nekoray'
    alias sing='sing-box run -c ~/.config/sing-box/config.json'
    alias wpscan="$HOME/.local/share/gem/ruby/3.3.0/bin/wpscan"
fi

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && \
    source "$HOME/.dart-cli-completion/zsh-config.zsh"

if [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Catppuccin Mocha palette for libnewt applications on Linux.
if [[ "$(uname -s)" == "Linux" ]]; then
    export NEWT_COLORS='
root=#cdd6f4,#1e1e2e
border=#cba6f7,#1e1e2e
window=#cdd6f4,#1e1e2e
shadow=#11111b,#11111b
title=#cba6f7,#1e1e2e
button=#1e1e2e,#b4befe
actbutton=#1e1e2e,#cba6f7
checkbox=#cdd6f4,#1e1e2e
actcheckbox=#cba6f7,#1e1e2e
entry=#cdd6f4,#313244
label=#cdd6f4,#1e1e2e
listbox=#cdd6f4,#313244
actlistbox=#1e1e2e,#cba6f7
textbox=#cdd6f4,#313244
acttextbox=#1e1e2e,#89b4fa
helpline=#1e1e2e,#89b4fa
roottext=#cdd6f4,#1e1e2e
emptyscale=#45475a,#1e1e2e
fullscale=#cba6f7,#1e1e2e
disentry=#6c7086,#313244
compactbutton=#cba6f7,#1e1e2e
actsellistbox=#1e1e2e,#cba6f7
sellistbox=#cba6f7,#313244
'
fi
