#!/bin/bash
# General purpose remote setup script for dotfiles
# Usage: ./remote-setup.sh user@remote-server [config-type]
# Examples:
#   ./remote-setup.sh user@server            # Deploy all configs
#   ./remote-setup.sh user@server tmux       # Deploy only tmux config
#   ./remote-setup.sh user@server shell      # Deploy only shell configs
#   ./remote-setup.sh user@server git        # Deploy only git configs

# Replace with your actual GitHub username
GITHUB_USER="yourusername"
REPO="dotfiles"
BRANCH="main"

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO/$BRANCH"

if [ $# -eq 0 ]; then
    echo "Usage: $0 user@remote-server [config-type]"
    echo "Available config types: all, tmux, shell, git, aws, ssh"
    exit 1
fi

REMOTE_HOST="$1"
CONFIG_TYPE="${2:-all}"  # Default to 'all' if not specified

# Function to generate a command to fetch a file from GitHub
fetch_file() {
    local file="$1"
    local dest="${2:-$file}"
    echo "mkdir -p \$(dirname \"$dest\") && curl -s $BASE_URL/$file > \"$dest\""
}

# Function to generate commands for different config types
generate_commands() {
    local type="$1"
    local commands=""
    
    case "$type" in
        "all" | "tmux")
            commands+="$(fetch_file .tmux.conf ~/.tmux.conf)"
            commands+="\ntmux source-file ~/.tmux.conf 2>/dev/null || echo 'Run tmux to apply configuration'"
            ;;
    esac
    
    case "$type" in
        "all" | "shell")
            if [ -f ~/dotfiles/.zshrc ]; then
                commands+="\n$(fetch_file .zshrc ~/.zshrc)"
            fi
            if [ -f ~/dotfiles/.bashrc ]; then
                commands+="\n$(fetch_file .bashrc ~/.bashrc)"
            fi
            if [ -f ~/dotfiles/.bash_profile ]; then
                commands+="\n$(fetch_file .bash_profile ~/.bash_profile)"
            fi
            ;;
    esac
    
    case "$type" in
        "all" | "git")
            if [ -f ~/dotfiles/.gitconfig ]; then
                commands+="\n$(fetch_file .gitconfig ~/.gitconfig)"
            fi
            if [ -f ~/dotfiles/.gitignore_global ]; then
                commands+="\n$(fetch_file .gitignore_global ~/.gitignore_global)"
            fi
            ;;
    esac
    
    case "$type" in
        "all" | "aws")
            if [ -f ~/dotfiles/.aws/config ]; then
                commands+="\n$(fetch_file .aws/config ~/.aws/config)"
            fi
            ;;
    esac
    
    case "$type" in
        "all" | "ssh")
            if [ -f ~/dotfiles/.ssh/config ]; then
                commands+="\n$(fetch_file .ssh/config ~/.ssh/config)"
                commands+="\nchmod 600 ~/.ssh/config"
            fi
            ;;
    esac
    
    echo -e "$commands"
}

# Generate the appropriate commands
COMMANDS=$(generate_commands "$CONFIG_TYPE")

# Option 1: Display commands for manual execution
echo "Run these commands on the remote server ($REMOTE_HOST):"
echo "-------------------------------------------"
echo -e "$COMMANDS"
echo "-------------------------------------------"
echo ""

# Option 2: Offer to execute the commands directly
read -p "Would you like to execute these commands on $REMOTE_HOST now? (y/n): " EXECUTE
if [[ $EXECUTE == "y" || $EXECUTE == "Y" ]]; then
    echo "Executing commands on $REMOTE_HOST..."
    ssh "$REMOTE_HOST" "$(echo -e "$COMMANDS")"
    echo "Done!"
fi

# Option 3: Offer to create a one-line setup script
read -p "Would you like to create a one-liner setup script? (y/n): " CREATE_SCRIPT
if [[ $CREATE_SCRIPT == "y" || $CREATE_SCRIPT == "Y" ]]; then
    ONELINER="curl -s https://raw.githubusercontent.com/$GITHUB_USER/$REPO/$BRANCH/remote-setup.sh | bash -s -- $CONFIG_TYPE"
    echo ""
    echo "One-liner for quick setup:"
    echo "-------------------------------------------"
    echo "$ONELINER"
    echo "-------------------------------------------"
fi
