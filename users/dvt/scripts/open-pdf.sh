DIRS=(
    "$HOME/Downloads"
    "$HOME/projects"
    "$HOME/Sync"
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . "${DIRS[@]}" --extension="epub" --extension="pdf" --full-path --base-directory "$HOME" \
        | sed "s|^$HOME/||" \
        | sort -uf \
        | fzf)

    # Add home path back
    if [[ -n "$selected" ]]; then
        selected="$HOME/$selected"
    fi
fi

# Quit if nothing selected
if [[ -z "$selected" ]]; then
    exit 0
fi

if [[ -n "${TMUX:-}" ]]; then
    tmux new-window -d "exec zathura $(printf '%q' "$selected")"
else
    exec zathura "$selected"
fi
