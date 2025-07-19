#!/bin/bash
# remote-setup.sh - Just download and apply dotfiles
# This is intended to be used on a remote server, not locally.
# The deploy-dotfiles.sh script is intended to be used on a local machine to deploy the dotfiles to a remote server.
set -e

GITHUB_USER="${GITHUB_USER:-Scottzonn}"
CONFIG_TYPE="${1:-tmux}"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/dotfiles/refs/heads/main"

# Download and apply configs
case "$CONFIG_TYPE" in
    tmux)
        echo "Setting up tmux..."
        curl -fsSL "$BASE_URL/.tmux.conf" > ~/.tmux.conf
        
        # Install TPM (Tmux Plugin Manager)
        if [ ! -d ~/.tmux/plugins/tpm ]; then
            echo "Installing TPM..."
            git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
            echo "✓ TPM installed"
        else
            echo "✓ TPM already installed"
        fi
        
        # Reload tmux if running
        tmux source ~/.tmux.conf 2>/dev/null || true
        echo "✓ Tmux configured"
        ;;
    
    shell)
        echo "Setting up shell..."
        if [ -n "$BASH_VERSION" ]; then
            curl -fsSL "$BASE_URL/.bashrc" > ~/.bashrc
            source ~/.bashrc
            echo "✓ Bash configured"
        elif [ -n "$ZSH_VERSION" ]; then
            curl -fsSL "$BASE_URL/.zshrc" > ~/.zshrc
            source ~/.zshrc
            echo "✓ Zsh configured"
        fi
        ;;
    
    git)
        echo "Setting up git..."
        curl -fsSL "$BASE_URL/.gitconfig" > ~/.gitconfig
        echo "✓ Git configured"
        ;;
    
    all)
        $0 tmux
        $0 shell
        $0 git
        ;;
    
    *)
        echo "Usage: $0 [tmux|shell|git|all]"
        exit 1
        ;;
esac