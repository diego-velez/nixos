# Directories to search within
DIRS=(
    "$HOME/projects"
    "$HOME/Sync/Courses/*/"
)

# Raw directories to use. They must be relative to "$HOME" but not include it.
EXTRA_DIRS=(
    "nixos"
)

# This skips fzf and just opens/moves to that project space
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(
        { printf '%s\n' "${EXTRA_DIRS[@]}"; \
          fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory "$HOME" \
              | sed "s|^$HOME/||"; } \
        | fzf
    )

    # Add home path back
    if [[ -n "$selected" ]]; then
        selected="$HOME/$selected"
    fi
fi

# Quit if nothing selected
if [[ -z "$selected" ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

if ! tmux has-session -t "$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
    # Select first window
    tmux select-window -t "$selected_name:1"
fi

tmux switch-client -t "$selected_name"
