{
  lib,
  pkgs,
  machine,
  ...
}:
{
  xdg.configFile = lib.mkIf (machine == "laptop") {
    "kanata/config.kbd".text = ''
      (defcfg
          process-unmapped-keys yes
      )

      (defsrc
          q w e r t y u i o p
          a s d f g h j k l ; '
          z x c v b n m
          tab caps spc
      )

      (deflayer base
          q w f p b j l u y '
          @cha r s t g m n e i @cho ;
          x c d v z k h
          caps tab @nav
      )

      ;; This is mapped using Qwerty
      (deflayermap (nav-layer)
          a lmeta s lalt d lshift f lctrl
          j left k down l up ; right
          m home , end
      )

      (defalias
          nav (tap-hold 200 200 spc (layer-while-held nav-layer))
          cha (chord escape-combo a)
          cho (chord escape-combo o)
      )

      (defchords escape-combo 35
          (a  ) a
          (  o) o
          (a o) esc
      )
    '';
  };

  systemd.user.services = lib.mkIf (machine == "laptop") {
    kanata = {
      Unit = {
        Description = "Kanata Keyboard remapper";
        Documentation = "https://github.com/jtroo/kanata";
      };

      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.kanata} --cfg %E/kanata/config.kbd";
        Restart = "no";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
