cd "$(tmux run "echo #{pane_start_path}")"
url=$(git remote get-url origin)

if [[ $url == git@github:* ]]; then
    url="${url#git@github:}"
    url="${url%.git}"
    url="https://github.com/$url"
    xdg-open "$url"
elif [[ $url == https://github.com* ]]; then
    xdg-open "$url"
else
    echo "Repository $url is not hosted on GitHub"
fi
