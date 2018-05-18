alias reload!='. ~/.zshrc'
alias dots="cd ~/.dotfiles && nvim ."

alias vim=nvim

alias g="jump"
alias s="mark"
alias d="unmark"
alias p="marks"

# tmux aliases
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'
alias ma='tmux attach || { (while ! tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh; do sleep 0.2; done)& tmux ; }'
