{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # purple, green, cyan, red, pink, yellow
      format = lib.concatStrings [
        "[](purple)"
        "$os"
        "$username"
        "[](bg:green fg:purple)"
        "$directory"
        "[](fg:green bg:cyan)"
        "$git_branch"
        "$git_status"
        "[](fg:cyan bg:red)"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "[](fg:red bg:pink)"
        "$docker_context"
        "[](fg:pink bg:yellow)"
        "$time"
        "[ ](fg:yellow)"
        "$fill"
        "$line_break$character"
      ];

      palette = "dracula";

      palettes.dracula = {
        background = "#282A36";
        foreground = "#F8F8F2";
        selection = "#44475A";
        comment = "#6272A4";
        red = "#FF5555";
        orange = "#FFB86C";
        yellow = "#F1FA8C";
        green = "#50FA7B";
        purple = "#BD93F9";
        cyan = "#8BE9FD";
        pink = "#FF79C6";
      };

      os = {
        disabled = false;
        style = "bg:purple fg:background";
        symbols = {
          Fedora = "󰣛";
          Arch = "󰣇";
          NixOS = "";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:purple fg:background bold";
        style_root = "bg:purple fg:background bold";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "fg:background bg:green bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      directory.substitutions = {
        Documents = "󰈙 ";
        Downloads = " ";
        Music = "󰝚 ";
        Pictures = " ";
        Developer = "󰲋 ";
      };
      git_branch = {
        symbol = "";
        style = "bg:cyan bold";
        format = "[[ $symbol $branch ](fg:background bg:cyan bold)]($style)";
      };

      git_status = {
        style = "bg:cyan bold";
        format = "[[($all_status$ahead_behind )](fg:background bg:cyan bold)]($style)";
      };

      # Language modules share the same style/format in your config
      nodejs = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:pink bold";
        format = "[[ $symbol( $context) ](fg:background bg:pink bold)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:yellow bold";
        format = "[[  $time ](fg:background bg:yellow bold)]($style)";
      };

      line_break.disabled = false;

      character = {
        disabled = false;
        success_symbol = " [󱞩](bold fg:green)";
        error_symbol = " [󱞩](bold fg:red)";
        vimcmd_symbol = " [󱞥](bold fg:yellow)";
        vimcmd_replace_one_symbol = " [󱞥](bold fg:purple)";
        vimcmd_replace_symbol = " [󱞥](bold fg:purple)";
        vimcmd_visual_symbol = " [󱞥](bold fg:pink)";
      };

      fill.symbol = "";
    };
  };
}
