{
  pkgs,
  pkgsUnstable,
  lib,
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

  time.timeZone = lib.mkDefault "America/Puerto_Rico";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
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

  services.xserver.enable = lib.mkDefault true;

  services.displayManager.gdm.enable = lib.mkDefault true;

  services.xserver.xkb = lib.mkDefault {
    layout = "us";
    variant = "";
  };

  services.printing.enable = lib.mkDefault true;

  services.pulseaudio.enable = lib.mkDefault false;
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = lib.mkDefault {
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

  programs.firefox.enable = lib.mkDefault true;
  programs.fish.enable = lib.mkDefault true;

  programs.niri.enable = true;

  nixpkgs.config.allowUnfree = lib.mkDefault true;
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

  services.openssh.enable = lib.mkDefault true;

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
