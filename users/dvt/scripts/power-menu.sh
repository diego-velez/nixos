shutdown="Shutdown"
shutdown_icon="\0icon\x1fsystem-shutdown"

restart="Restart"
reboot_icon="\0icon\x1fsystem-restart"

suspend="Suspend"
suspend_icon="\0icon\x1fsystem-suspend"

lock="Lock"
lock_icon="\0icon\x1flock"

logout="Logout"
logout_icon="\0icon\x1fsystem-log-out"

options="$shutdown$shutdown_icon\n$restart$reboot_icon\n$suspend$suspend_icon\n$lock$lock_icon\n$logout$logout_icon"

# See https://github.com/m4thewz/dracula-icons
choice=$(echo -e "$options" | fuzzel --dmenu --hide-prompt --icon-theme="Dracula" --font=":size=@fontSize@")
case "$choice" in
    "$shutdown")
        systemctl poweroff
        ;;
    "$restart")
        systemctl reboot
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$lock")
        loginctl lock-session
        ;;
    "$logout")
        loginctl terminate-session self
        ;;
esac
