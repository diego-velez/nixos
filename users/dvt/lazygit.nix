{ ... }:
{
  programs.lazygit = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      gui = {
        language = "en";
        timeFormat = "02 January 2006";
        shortTimeFormat = "15:04";
        nerdFontsVersion = "3";
        showFileIcons = true;
        spinner = {
          frames = [
            "⠋"
            "⠙"
            "⠹"
            "⠸"
            "⠼"
            "⠴"
            "⠦"
            "⠧"
            "⠇"
            "⠏"
          ];
          rate = 50;
        };
      };
      git = {
        parseEmoji = true;
        disableForcePushing = true;
      };
      disableStartupPopups = true;
    };
  };
}
