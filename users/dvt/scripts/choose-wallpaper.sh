WP_FOLDER="@wallpaperFolder@"

while true; do
    WP_CHOSEN="$(find "$WP_FOLDER" -maxdepth 1 -type f -printf "%f\n" | fuzzel --dmenu --prompt "Wallpaper (ESC to exit) > ")"
    if [ -z "$WP_CHOSEN" ]; then
        exit 0
    fi

    set-wallpaper "$WP_FOLDER/$WP_CHOSEN"
done
