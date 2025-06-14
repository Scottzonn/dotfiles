#!/bin/bash
# deploy-dotfiles - Generate dotfiles setup command

GITHUB_USER="${DOTFILES_GITHUB_USER:-Scottzonn}"

# Get config type
echo "Configuration type [tmux/shell/git/all]: "
read -r config_type
config_type=${config_type:-tmux}

# Build command
cmd="curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/dotfiles/main/remote-setup.sh | bash -s -- $config_type"

# Display command
echo
echo "Run this command on your remote server:"
echo
echo "    $cmd"
echo

# Copy to clipboard if available
if command -v pbcopy > /dev/null 2>&1; then
    echo "$cmd" | pbcopy
    echo "✓ Command copied to clipboard!"
elif command -v xclip > /dev/null 2>&1; then
    echo "$cmd" | xclip -selection clipboard
    echo "✓ Command copied to clipboard!"
fi