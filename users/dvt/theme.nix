{ pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };

    # This silences the following warning:
    #
    #     evaluation warning:
    #     The default value of `gtk.gtk4.theme` has changed from `config.gtk.theme` to `null`.
    #     You are currently using the legacy default (`config.gtk.theme`)
    #     because `home.stateVersion` is less than "26.05".
    #     To silence this warning and keep legacy behavior, set: gtk.gtk4.theme = config.gtk.theme;
    #     To adopt the new default behavior, set: gtk.gtk4.theme = null;
    gtk4.theme = null;
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name = "graphite-light";
    package = pkgs.graphite-cursors;
    size = 26;
  };
}
