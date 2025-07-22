# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing development environment configurations. It focuses on shell environment (Zsh), terminal multiplexer (tmux), and system package management (Homebrew).

## Key Commands

### Deployment Commands

- **Generate deployment command**: `./deploy-dotfiles.sh`
- **Deploy to remote server**: `curl -fsSL https://raw.githubusercontent.com/Scottzonn/dotfiles/main/remote-setup.sh | bash -s -- <type>`
  - Types: `tmux`, `shell`, `git`, or `all`

### Git Commands

- **Commit changes**: Run after making changes to push updates that will be available for remote deployment

## Architecture and Structure

### Core Configuration Files

1. **`.zshrc`** - Main shell configuration
   - Sets up Oh My Zsh with plugins
   - Configures development environments (Python, Node.js, Java)
   - Defines aliases and environment variables
   - Integrates with direnv for automatic environment loading

2. **`.tmux.conf`** - Terminal multiplexer configuration
   - Uses `C-Space` as prefix (not default `C-b`)
   - Vim-style keybindings for navigation
   - Plugin management via TPM
   - Catppuccin theme with sensible defaults

3. **`Brewfile`** - System dependencies
   - Development tools, databases, cloud CLIs
   - Desktop applications
   - Media processing utilities

### Deployment System

The repository uses a two-script deployment system:

1. **`deploy-dotfiles.sh`** - Local helper that generates deployment commands
2. **`remote-setup.sh`** - Downloads and applies configurations on target systems

This design allows for:
- Selective deployment (individual components or all)
- No need to clone the entire repository on remote servers
- Direct execution via curl from GitHub

## Development Notes

- When modifying configurations, test locally before pushing
- The remote deployment pulls from the GitHub repository, so changes must be committed and pushed to take effect remotely
- tmux plugin installation happens automatically on first run after deployment
- Shell configurations support both bash and zsh environments