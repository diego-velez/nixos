WP_FOLDER="@wallpaperFolder@"
WP_CHOSEN="$(find "$WP_FOLDER" -type f | shuf -n 1)"
set-wallpaper "$WP_CHOSEN"
