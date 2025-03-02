#!/usr/bin/env bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
    echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
    echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
    exit 1
}

warning() {
    echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
    echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
    echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

get_linkables() {
    find -H "$DOTFILES" -maxdepth 3 -name '*.symlink'
}

setup_symlinks() {
    title "Creating symlinks"
    BACKUP_DIR=$HOME/dotfiles-backup

    # Create symlinks for *.symlink files
    for file in $(get_linkables) ; do
        target="$HOME/.$(basename "$file" '.symlink')"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists... Skipping."
        else
            info "Creating symlink for $file"
            ln -s "$file" "$target"
        fi
    done

    # Explicitly ensure zshenv.symlink is linked
    if [ -e "$HOME/.zshenv" ]; then
        info "~/.zshenv already exists... Skipping."
    else
        info "Creating symlink for $DOTFILES/zshenv.symlink"
        ln -s "$DOTFILES/zshenv.symlink" "$HOME/.zshenv"
    fi

    echo -e
    info "installing to ~/.config"
    if [ ! -d "$HOME/.config" ]; then
        info "Creating ~/.config"
        mkdir -p "$HOME/.config"
    fi

    # Create symlinks for config folders
    config_files=$(find "$DOTFILES/config" -maxdepth 1 -type d 2>/dev/null)
    for config in $config_files; do
        # Skip the config directory itself
        if [ "$config" = "$DOTFILES/config" ]; then
            continue
        fi
        
        target="$HOME/.config/$(basename "$config")"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists."
            read -rp "Do you want to backup? [y/N] " backup
            if [[ $backup =~ ^([Yy])$ ]]; then
                # Backup to BACKUP_DIR
                info "Backing up to $BACKUP_DIR/$(basename "$target")"
                mkdir -p "$BACKUP_DIR"
                cp -r "$target" "$BACKUP_DIR"
                success "Backup created at $BACKUP_DIR/$(basename "$target")"
            fi
            # Remove existing folder
            info "Removing existing folder at $target"
            rm -rf "$target"
        fi
        # Create symlink
        info "Creating symlink for $config"
        ln -s "$config" "$target"
    done
    
    # Handle individual files in config directory
    config_files=$(find "$DOTFILES/config" -maxdepth 1 -type f 2>/dev/null)
    for config in $config_files; do
        target="$HOME/.config/$(basename "$config")"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists."
            read -rp "Do you want to backup? [y/N] " backup
            if [[ $backup =~ ^([Yy])$ ]]; then
                # Backup to BACKUP_DIR
                info "Backing up to $BACKUP_DIR/$(basename "$target")"
                mkdir -p "$BACKUP_DIR"
                cp "$target" "$BACKUP_DIR"
                success "Backup created at $BACKUP_DIR/$(basename "$target")"
            fi
            # Remove existing file
            info "Removing existing file at $target"
            rm -f "$target"
        fi
        # Create symlink
        info "Creating symlink for $config"
        ln -s "$config" "$target"
    done
}

setup_git() {
    title "Setting up Git"

    defaultName=$(git config user.name)
    defaultEmail=$(git config user.email)
    defaultGithub=$(git config github.user)

    read -rp "Name [$defaultName] " name
    read -rp "Email [$defaultEmail] " email
    read -rp "Github username [$defaultGithub] " github

    git config -f ~/.gitconfig-local user.name "${name:-$defaultName}"
    git config -f ~/.gitconfig-local user.email "${email:-$defaultEmail}"
    git config -f ~/.gitconfig-local github.user "${github:-$defaultGithub}"

    if [[ "$(uname)" == "Darwin" ]]; then
        git config --global credential.helper "osxkeychain"
    else
        read -rn 1 -p "Save user and password to an unencrypted file to avoid writing? [y/N] " save
        if [[ $save =~ ^([Yy])$ ]]; then
            git config --global credential.helper "store"
        else
            git config --global credential.helper "cache --timeout 3600"
        fi
    fi
}

function setup_terminfo() {
    title "Configuring terminfo"

    info "adding tmux.terminfo"
    tic -x "$DOTFILES/resources/tmux.terminfo"

    info "adding xterm-256color-italic.terminfo"
    tic -x "$DOTFILES/resources/xterm-256color-italic.terminfo"
}

function sync_dotfiles() {
    title "Syncing dotfiles"
    
    if [ ! -d "$HOME/.config" ]; then
        info "Creating ~/.config"
        mkdir -p "$HOME/.config"
    fi
    
    # Find all directories in ~/.dotfiles
    dotfiles_dirs=$(find "$HOME/.dotfiles" -type d -not -path "*/\.*" -not -path "$HOME/.dotfiles" 2>/dev/null)
    
    for dir in $dotfiles_dirs; do
        # Get the relative path from ~/.dotfiles
        rel_path=${dir#"$HOME/.dotfiles/"}
        
        # Skip the config directory as it's handled by setup_symlinks
        if [[ "$rel_path" == "config" ]]; then
            continue
        fi
        
        # Check if this is a subdirectory of config
        if [[ "$rel_path" == config/* ]]; then
            # For config subdirectories, we want to link them to ~/.config
            config_subdir=${rel_path#"config/"}
            target="$HOME/.config/$config_subdir"
            
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                info "~${target#$HOME} already exists... Skipping."
            elif [ -L "$target" ]; then
                info "~${target#$HOME} is already a symlink... Skipping."
            else
                info "Creating symlink for $dir to $target"
                mkdir -p "$(dirname "$target")"
                ln -s "$dir" "$target"
                success "Created symlink for $dir"
            fi
        # Handle other directories that should be linked to ~/.config
        elif [ -d "$dir" ] && [[ "$rel_path" != "resources" ]] && [[ "$rel_path" != "bin" ]]; then
            # For other directories, check if they should be linked to ~/.config
            target="$HOME/.config/$(basename "$dir")"
            
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                info "~${target#$HOME} already exists... Skipping."
            elif [ -L "$target" ]; then
                info "~${target#$HOME} is already a symlink... Skipping."
            else
                info "Creating symlink for $dir to $target"
                ln -s "$dir" "$target"
                success "Created symlink for $dir"
            fi
        fi
    done
}

case "$1" in
    link)
        setup_symlinks
        ;;
    git)
        setup_git
        ;;
    terminfo)
        setup_terminfo
        ;;
    sync)
        sync_dotfiles
        ;;
    *)
        echo -e $"\nUsage: $(basename "$0") {link|git|terminfo|sync}\n"
        exit 1
        ;;
esac

echo -e
success "Done."
