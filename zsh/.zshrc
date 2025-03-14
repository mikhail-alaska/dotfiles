# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [ $TERM = "xterm-256color" ] ; then
else
    fastfetch
fi







ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"


# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
#zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
# Load completions
autoload -Uz compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups



# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# Aliases
alias vpn='nekobox'
alias ls='ls --color'
alias ll='ls -latr'
alias vim='nvim'
alias c='clear'
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'
alias wpscan='/home/alaska/.local/share/gem/ruby/3.3.0/bin/wpscan'
alias lock='hyprlock'
# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

export PATH=$PATH:$HOME/.local/bin

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/alaska/.dart-cli-completion/zsh-config.zsh ]] && . /home/alaska/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# bun completions
[ -s "/home/alaska/.bun/_bun" ] && source "/home/alaska/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/dotfiles/p10k/.p10k.zsh.
#[[ ! -f ~/dotfiles/p10k/.p10k.zsh ]] || source ~/dotfiles/p10k/.p10k.zsh
eval "$(starship init zsh)"
