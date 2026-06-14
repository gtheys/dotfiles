export ZSH=$ZDOTDIR

# Ensure functions directory is in fpath
if [[ -d $ZDOTDIR/functions ]]; then
    if [[ $fpath[(i)$ZDOTDIR/functions] -gt $#fpath ]]; then
        fpath=($ZDOTDIR/functions $fpath)
    fi
    
    # Autoload all functions
    for func in $ZDOTDIR/functions/*(:t); do
        autoload -Uz $func
    done
fi

########################################################
# Configuration
########################################################

# Set this to the path of the opencode repo
# Goal is to add the bin to the path

prepend_path $HOME/Code/salaryhero/opencode/bin/

# initialize autocomplete
# AIDEV-NOTE: Use cached compinit (-C) when dump is <24h old to skip slow fpath rescan
autoload -Uz compinit add-zsh-hook
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# source alias file if it exists
[ -f "$ZDOTDIR/alias" ] && source "$ZDOTDIR/alias"

# Use prepend_path
prepend_path $HOME/.config/scripts
prepend_path /usr/local/opt/grep/libexec/gnubin
prepend_path /usr/local/sbin
prepend_path $DOTFILES/bin
prepend_path $HOME/bin
prepend_path $HOME/.local/bin
prepend_path $HOME/.cargo/bin
prepend_path ${ASDF_DATA_DIR:-$HOME/.asdf}/shims
# AIDEV-NOTE: npm/bin prepended after mise activation (see below) to ensure mise-managed npm overrides node-bundled npm
prepend_path $HOME/.bun/bin
prepend_path /opt/cuda/bin

export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH

# define the code directory
# This is where my code exists and where I want the `c` autocomplete to work from exclusively
if [[ -d ~/code ]]; then
    export CODE_DIR=~/code
elif [[ -d ~/Developer ]]; then
    export CODE_DIR=~/Developer
fi

export DEVCTL_INFRA_DIR=~/Code/salaryhero/infra
# AIDEV-NOTE: Cache GH_TOKEN — `gh auth token` forks on every startup otherwise.
# Refreshed when the cache file is older than 24h.
_gh_token_cache="$CACHEDIR/gh-token"
if [[ ! -f "$_gh_token_cache" || -n "${_gh_token_cache}(#qN.mh+24)" ]]; then
    mkdir -p "$(dirname "$_gh_token_cache")"
    gh auth token > "$_gh_token_cache" 2>/dev/null
fi
[[ -s "$_gh_token_cache" ]] && export GH_TOKEN=$(< "$_gh_token_cache")
unset _gh_token_cache

# display how long all tasks over 10 seconds take
export REPORTTIME=10
export KEYTIMEOUT=1              # 10ms delay for key sequences
export THEME_FLAVOUR=mocha

setopt NO_BG_NICE
setopt NO_HUP                    # don't kill background jobs when the shell exits
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # write the history file in the ":start:elapsed;command" format.
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry.
setopt SHARE_HISTORY             # share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate.

setopt COMPLETE_ALIASES

# make terminal command navigation sane again
bindkey "^[[1;5C" forward-word                      # [Ctrl-right] - forward one word
bindkey "^[[1;5D" backward-word                     # [Ctrl-left] - backward one word
bindkey '^[^[[C' forward-word                       # [Ctrl-right] - forward one word
bindkey '^[^[[D' backward-word                      # [Ctrl-left] - backward one word
bindkey '^[[1;3D' beginning-of-line                 # [Alt-left] - beginning of line
bindkey '^[[1;3C' end-of-line                       # [Alt-right] - end of line
bindkey '^[[5D' beginning-of-line                   # [Alt-left] - beginning of line
bindkey '^[[5C' end-of-line                         # [Alt-right] - end of line
bindkey '^?' backward-delete-char                   # [Backspace] - delete backward
if [[ "${terminfo[kdch1]}" != "" ]]; then
    bindkey "${terminfo[kdch1]}" delete-char        # [Delete] - delete forward
else
    bindkey "^[[3~" delete-char                     # [Delete] - delete forward
    bindkey "^[3;5~" delete-char
    bindkey "\e[3~" delete-char
fi
# AIDEV-NOTE: Moved Ctrl-e/Ctrl-f binds into the default keymap — the -M viins versions
# were dead (vi mode is never enabled; no `bindkey -v`). Add `bindkey -v` to use vi mode.
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^F" forward-word                          # [Ctrl-f] - move to next word
bindkey "^J" history-beginning-search-forward
bindkey "^K" history-beginning-search-backward

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# default to file completion
zstyle ':completion:*' completer _expand _complete _files _correct _approximate

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''


########################################################
# Plugin setup
########################################################

export ZPLUGDIR="$CACHEDIR/zsh/plugins"
[[ -d "$ZPLUGDIR" ]] || mkdir -p "$ZPLUGDIR"
# array containing plugin information (managed by zfetch)
typeset -A plugins

zfetch mafredri/zsh-async async.plugin.zsh
zfetch zsh-users/zsh-syntax-highlighting
zfetch zsh-users/zsh-autosuggestions
zfetch grigorii-zander/zsh-npm-scripts-autocomplete
zfetch Aloxaf/fzf-tab
zfetch alberti42/zsh-opencode-tab

# AIDEV-NOTE: fnm removed — mise is the sole node version manager (see activate below).
# Re-add only if mise can't handle a workflow.

[[ -e ~/.terminfo ]] && export TERMINFO_DIRS=~/.terminfo:/usr/share/terminfo

########################################################
# Various Configuration
########################################################

# Podman configuration settings

# export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock
# export UID=$(id -u)
# export GID=$(id -g)
#
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# AIDEV-NOTE: Cache vivid output to avoid subprocess on every shell start
_vivid_cache="$HOME/.cache/ls-colors.env"
if [[ ! -f "$_vivid_cache" ]]; then
    mkdir -p "$(dirname "$_vivid_cache")"
    vivid generate tokyonight-storm > "$_vivid_cache"
fi
export LS_COLORS=$(< "$_vivid_cache")
unset _vivid_cache

export PLAYWRIGHT_MCP_BROWSER=firefox


########################################################
# Setup
########################################################

#if [ -f $HOME/.fzf.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
  #source $HOME/.fzf.zsh
  export FZF_DEFAULT_COMMAND='fd --type f'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--color bg:-1,bg+:-1,fg:-1,fg+:#feffff,hl:#993f84,hl+:#d256b5,info:#676767,prompt:#676767,pointer:#676767"
#fi

# add color to man pages
export MANROFFOPT='-c'
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
export LESS_TERMCAP_md=$(tput bold; tput setaf 6)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)

# prefer zoxide over z.sh
if [[ -x "$(command -v zoxide)" ]]; then
    eval "$(zoxide init zsh --hook pwd)"
fi

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # macOS `ls`
    colorflag="-G"
fi

# if uwsm check may-start && uwsm select; then
# 	exec uwsm start default
# fi
#
# If a ~/.zshrc.local exists, source it
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
# If a ~/.localrc zshrc exists, source it
[[ -a ~/.localrc ]] && source ~/.localrc

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# AIDEV-NOTE: No 1Password/Docker calls at startup — all are slow (op signin ~400ms,
# op environment read ~6.5s, docker info times out when daemon is down). Modern `op`
# auths lazily via biometrics; run `op-env` (bottom of file) to load secrets on demand.

# AIDEV-NOTE: Single mise activation — this is the sole node version manager (fnm removed).
# Activate without --shims to avoid full shell integration overhead; use hooks if auto-install needed.
eval "$(command mise activate zsh)"
prepend_path $HOME/.local/share/npm/bin

# AIDEV-NOTE: Cache git town completions to file — avoids subprocess fork on every start
_gt_comp="$HOME/.cache/git-town-completions.zsh"
[[ -f "$_gt_comp" ]] || git town completions zsh > "$_gt_comp"
source "$_gt_comp"
unset _gt_comp
# FZF with Git right in the shell by Junegunn : check out his github below
# Keymaps for this is available at https://github.com/junegunn/fzf-git.sh
source ~/.config/scripts/fzf-git.sh

# AIDEV-NOTE: op secrets loaded lazily — `op environment read` takes ~6.5s per call.
# Run `op-env` to export the item's secrets into the current shell when needed.
op-env() { eval "$(op environment read 27kxanp7phjmomdvyjvynbw57y)"; }
