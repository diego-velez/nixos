FPS=120
WP_DIR="$HOME/Pictures/Wallpapers/"
WP_CHOSEN="$(find "$WP_DIR" -type f | shuf -n 1)"
DEST_FILE="$HOME/.config/swaylock/wallpaper"
awww img "$WP_CHOSEN" --transition-type any --transition-fps $FPS
ln -f "$WP_CHOSEN" "$DEST_FILE"
