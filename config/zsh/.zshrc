export ZSH=$ZDOTDIR

# Ensure functions directory is in fpath
if [[ -d $ZDOTDIR/functions ]]; then
    if [[ $fpath[(i)$ZDOTDIR/functions] -gt $#fpath ]]; then
        fpath=($ZDOTDIR/functions $fpath)
    fi
    
    # Autoload all functions
    for func in $ZDOTDIR/functions/*(:t); do
        autoload -U $func
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
bindkey "^A" vi-beginning-of-line
bindkey -M viins "^F" vi-forward-word               # [Ctrl-f] - move to next word
bindkey -M viins "^E" vi-add-eol                    # [Ctrl-e] - move to end of line
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

if [[ -x "$(command -v fnm)" ]]; then
    eval "$(fnm env --use-on-cd)"
fi

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
eval "$(op signin)"

# AIDEV-NOTE: Removed docker info check — it blocks startup (socket timeout) when Docker
# is not running. Run `eval $(minikube -p minikube docker-env)` manually when needed.

# AIDEV-NOTE: Removed `op signin` as it blocks shell startup. Modern 1Password CLI
# prompts for biometric auth lazily when needed. Add back only if specific tools break.

# AIDEV-NOTE: Single mise activation — --shims adds shims to PATH without full shell
# integration overhead. Use first form (no --shims) if mise hooks (e.g. auto-install) are needed.
eval "$(/usr/bin/mise activate zsh)"
prepend_path $HOME/.local/share/npm/bin

# AIDEV-NOTE: Cache git town completions to file — avoids subprocess fork on every start
_gt_comp="$HOME/.cache/git-town-completions.zsh"
[[ -f "$_gt_comp" ]] || git town completions zsh > "$_gt_comp"
source "$_gt_comp"
unset _gt_comp
# FZF with Git right in the shell by Junegunn : check out his github below
# Keymaps for this is available at https://github.com/junegunn/fzf-git.sh
source ~/.config/scripts/fzf-git.sh


## Export my API keys with 1 password
# AIDEV-NOTE: Cache LLM keys locally to avoid blocking shell startup with `op read`.
# Keys are refreshed from 1Password only when the cache is older than 24 hours.
__llm_keys_cache="$HOME/.cache/llm-keys.env"

_load_llm_keys() {
    # AIDEV-NOTE: Avoid creating an empty cache or exporting empty variables
    # if the 1Password CLI is not available or not signed in.
    if [[ -f "$__llm_keys_cache" ]] && [[ -z "$(find "$__llm_keys_cache" -mtime +0 2>/dev/null)" ]]; then
        source "$__llm_keys_cache"
    elif command -v op &>/dev/null; then
        # Check if op is signed in. If not, skip loading keys to avoid blocking
        # or creating an empty cache file.
        if ! op whoami &>/dev/null; then
            return
        fi

        mkdir -p "$(dirname "$__llm_keys_cache")"

        # Read keys into variables first so we can detect if all are empty.
        anth="$(op read "op://Personal/llm-keys/anthropic_key" 2>/dev/null)"
        openai="$(op read "op://Personal/llm-keys/openai_key" 2>/dev/null)"
        opencode="$(op read "op://Personal/llm-keys/opencode_key" 2>/dev/null)"
        gemini="$(op read "op://Personal/llm-keys/gemini_key" 2>/dev/null)"
        sonar="$(op read "op://Personal/llm-keys/sonar_key" 2>/dev/null)"

        # If all reads failed or returned empty, do not write the cache.
        if [[ -z "$anth" && -z "$openai" && -z "$opencode" && -z "$gemini" ]]; then
            return
        fi

        {
            echo "export ANTHROPIC_API_KEY='$anth'"
            echo "export OPENAI_API_KEY='$openai'"
            echo "export OPENCODE_API_KEY='$opencode'"
            echo "export GEMINI_API_KEY='$gemini'"
            echo "export SONARQUBE_TOKEN='$sonar'"
        } > "$__llm_keys_cache"
        chmod 600 "$__llm_keys_cache"
        source "$__llm_keys_cache"
    fi
}

_load_llm_keys
unfunction _load_llm_keys
unset __llm_keys_cache
