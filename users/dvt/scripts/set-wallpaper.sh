WP_PATH="$1"
if [ -z "$WP_PATH" ]; then
    echo "Usage: $0 <wallpaper-path>"
    exit 1
fi

FPS=120
DEST_FILE="$HOME/.config/swaylock/wallpaper"
awww img "$WP_PATH" --transition-type any --transition-fps $FPS
cp -f "$WP_PATH" "$DEST_FILE"
