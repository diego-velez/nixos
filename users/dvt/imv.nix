{
  programs.imv = {
    enable = true;
    settings = {
      options = {
        background = "282A36";
      };

      binds = {
        q = "quit";
        c = "center";
        r = "reset";
        y = ''exec wl-copy "$imv_current_file"'';

        # Panning
        "<Left>" = "pan 50 0";
        "<Right>" = "pan -50 0";
        "<Up>" = "pan 0 50";
        "<Down>" = "pan 0 -50";

        # Image navigation
        n = "next";
        p = "prev";
        gg = "goto 1";
        "<Shift+G>" = "goto -1";

        # Zooming
        i = "zoom 1";
        o = "zoom -1";
        a = "zoom actual";
      };
    };
  };
}
