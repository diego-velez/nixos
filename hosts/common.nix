{
  pkgs,
  pkgsUnstable,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };

  time.timeZone = "America/Puerto_Rico";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  hardware.bluetooth = {
    enable = true;
    settings = {
      General.Enable = "Source,Sink,Media,Socket";
      General.Experimental = true;
    };
  };

  services.blueman.enable = true;

  services.pulseaudio.configFile = pkgs.writeText "default.pa" ''
    load-module module-bluetooth-policy
    load-module module-bluetooth-discover
    ## module fails to load with
    ##   module-bluez5-device.c: Failed to get device path from module arguments
    ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
    # load-module module-bluez5-device
    # load-module module-bluez5-discover
  '';

  services.pulseaudio.extraConfig = "
    load-module module-switch-on-connect
  ";

  services.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.dvt = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Diego Velez";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
      "docker"
    ];
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.niri = {
    enable = true;
    package = pkgsUnstable.niri;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    # Enable flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Rebuild faster by using all CPU cores
    max-jobs = "auto";
    cores = 0;
  };

  # Periodically optimize nix store
  # See https://wiki.nixos.org/wiki/Storage_optimization#Automatic
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    wget
    ripgrep
    zoxide
    git
    vim
    pkgsUnstable.neovim
    wezterm
    waybar
    fuzzel
    eza
    atuin
    starship
    fortune
    bat
    fd
    rhythmbox
    xfce.thunar
    fastfetch
    zathura
    swayidle
    ungoogled-chromium
    mpv
    cowsay
    keepassxc
    ferdium
    localsend
    qalculate-gtk
    onlyoffice-desktopeditors
    xwayland-satellite
    lazydocker
    typst
    libnotify
    mako
    wl-clipboard
    syncthing
    quickshell
    nixd
    dracula-theme
    dracula-icon-theme
    psmisc
    playerctl
    clinfo
    pavucontrol
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 5";
    flake = "/home/dvt/nixos";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    ubuntu-sans
    cm_unicode
    corefonts
    unifont
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Ubuntu Sans" ];
    sansSerif = [ "Ubuntu Sans" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  services.openssh.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgsUnstable; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      libgcc
    ];
  };

  virtualisation.docker = {
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
