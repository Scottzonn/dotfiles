#!/bin/bash
# Deploy dotfiles to SSH sessions

GITHUB_USER="${DOTFILES_GITHUB_USER:-Scottzonn}"

# Get active SSH connections
get_ssh_connections() {
    ps aux | grep "[s]sh " | grep -v "sshd" | grep -v "ssh-agent"
}

# Extract hostname from SSH command (improved)
extract_hostname() {
    local cmd="$1"
    # Remove PID and 'ssh', then get the last non-flag argument
    echo "$cmd" | sed 's/^[^ ]* *//' | sed 's/.*ssh //' | 
        awk '{for(i=1;i<=NF;i++) if($i !~ /^-/) last=$i} END{print last}'
}

# Main
echo "Active SSH connections:"
echo "-----------------------"

connections=$(get_ssh_connections)
if [ -z "$connections" ]; then
    echo "No active SSH connections found."
    echo "[1] Create a new SSH connection"
    pids[1]=""
    hosts[1]=""
    max=1
else
    i=1
    while IFS= read -r line; do
        pid=$(echo "$line" | awk '{print $2}')
        host=$(extract_hostname "$line")
        [ -n "$host" ] && echo "[$i] $host (PID: $pid)" || echo "[$i] Unknown host (PID: $pid)"
        pids[$i]=$pid
        hosts[$i]=$host
        ((i++))
    done <<< "$connections"
    echo "[$i] Create a new SSH connection"
    max=$i
fi

echo "-----------------------"
read -p "Select a connection (1-$max): " selection

if [ "$selection" -lt 1 ] || [ "$selection" -gt "$max" ]; then
    echo "Invalid selection."
    exit 1
fi

read -p "Configuration type [tmux/shell/git/all]: " config_type
config_type=${config_type:-tmux}

# Build the command
cmd="curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/dotfiles/main/remote-setup.sh | bash -s -- $config_type"

if [ "$selection" -eq "$max" ]; then
    # New connection
    read -p "Enter hostname (user@host): " new_host
    echo "Connecting to $new_host..."
    ssh -t "$new_host" "$cmd"
else
    # Existing connection - just provide the command
    echo
    echo "Run this command in your SSH session with ${hosts[$selection]:-'the remote host'}:"
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
fi