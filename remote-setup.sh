#!/bin/bash
# remote-setup.sh - Just download and apply dotfiles
# This is intended to be used on a remote server, not locally.
# The deploy-dotfiles.sh script is intended to be used on a local machine to deploy the dotfiles to a remote server.
# Updated: 2025-08-03 - Fixed plugin installation order and error handling
set -e

GITHUB_USER="${GITHUB_USER:-Scottzonn}"
CONFIG_TYPE="${1:-tmux}"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/dotfiles/refs/heads/main"

# Download and apply configs
case "$CONFIG_TYPE" in
    tmux)
        echo "Setting up tmux..."
        
        # Download tmux config first
        echo "Downloading tmux configuration..."
        if ! curl -fsSL "$BASE_URL/.tmux.conf" -o ~/.tmux.conf; then
            echo "Error: Failed to download .tmux.conf"
            echo "Try manually: curl -fsSL $BASE_URL/.tmux.conf -o ~/.tmux.conf"
            exit 1
        fi
        echo "✓ Tmux config downloaded"
        
        # Install TPM (Tmux Plugin Manager)
        if [ ! -d ~/.tmux/plugins/tpm ]; then
            echo "Installing TPM..."
            git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
            echo "✓ TPM installed"
        else
            echo "✓ TPM already installed"
        fi
        
        # Install tmux plugins (only if tmux.conf exists and has plugin config)
        if grep -q "@plugin" ~/.tmux.conf 2>/dev/null; then
            echo "Installing tmux plugins..."
            if ~/.tmux/plugins/tpm/bin/install_plugins; then
                echo "✓ Tmux plugins installed"
            else
                echo "Warning: Plugin installation failed. You can install manually with: C-Space + I"
            fi
        else
            echo "No plugins configured in tmux.conf"
        fi
        
        # Reload tmux if running
        echo "sourcing new conf..."
        tmux source ~/.tmux.conf 2>/dev/null || true
        echo "✓ Tmux configured"
        ;;
    
    shell)
        echo "Setting up shell..."
        if [ -n "$BASH_VERSION" ]; then
            if ! touch ~/.bashrc 2>/dev/null; then
                echo "Warning: Cannot write to ~/.bashrc. Check file permissions."
                echo "You may need to run: sudo chown $USER:$USER ~/.bashrc"
                exit 1
            fi
            curl -fsSL "$BASE_URL/.bashrc" -o ~/.bashrc
            source ~/.bashrc
            echo "✓ Bash configured"
        elif [ -n "$ZSH_VERSION" ]; then
            if ! touch ~/.zshrc 2>/dev/null; then
                echo "Warning: Cannot write to ~/.zshrc. Check file permissions."
                echo "You may need to run: sudo chown $USER:$USER ~/.zshrc"
                exit 1
            fi
            curl -fsSL "$BASE_URL/.zshrc" -o ~/.zshrc
            source ~/.zshrc
            echo "✓ Zsh configured"
        fi
        ;;
    
    git)
        echo "Setting up git..."
        if ! touch ~/.gitconfig 2>/dev/null; then
            echo "Warning: Cannot write to ~/.gitconfig. Check file permissions."
            echo "You may need to run: sudo chown $USER:$USER ~/.gitconfig"
            exit 1
        fi
        curl -fsSL "$BASE_URL/.gitconfig" -o ~/.gitconfig
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