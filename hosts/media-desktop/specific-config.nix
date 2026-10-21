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

  time.timeZone = "America/Los_Angeles";

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

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "party";
  };

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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users = {
    dvt = {
      isNormalUser = true;
      shell = pkgs.fish;
      initialHashedPassword = "$y$j9T$dCe69c2lQuu8AFJnKwYpg1$DmMqWr4O4ms6IR5z2pzxPZiYXtbrJx5MRIUj1DXRGp7";
      description = "Diego Velez";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "uinput"
        "docker"
        "libvirtd"
      ];
    };
    party = {
      isNormalUser = true;
      shell = pkgs.fish;
      initialHashedPassword = "$y$j9T$dCe69c2lQuu8AFJnKwYpg1$DmMqWr4O4ms6IR5z2pzxPZiYXtbrJx5MRIUj1DXRGp7";
      description = "Life of the Party";
      extraGroups = [
        "networkmanager"
        "input"
        "uinput"
        "docker"
        "libvirtd"
      ];
    };
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.localsend.enable = true;
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    # Enable flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # 8 jobs each using 3 cores is 8 x 3 = 24 core CPU,
    # meaning that the sysem will use all CPU cores during rebuild
    max-jobs = 8;
    cores = 3;
  };

  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass = "best-effort";
  nix.daemonIOSchedPriority = 1;

  # Periodically optimize nix store
  # See https://wiki.nixos.org/wiki/Storage_optimization#Automatic
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    # KDE Utilities
    kdePackages.discover # Optional: Software center for Flatpaks/firmware updates
    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Character map
    kdePackages.kclock # Clock app
    kdePackages.kcolorchooser # Color picker
    kdePackages.kolourpaint # Simple paint program
    kdePackages.ksystemlog # System log viewer
    kdePackages.sddm-kcm # SDDM configuration module
    pkgsUnstable.kdePackages.plasma-bigscreen # Plasma shell for TVs
    kdiff3 # File/directory comparison tool

    # Hardware/System Utilities (Optional)
    kdePackages.isoimagewriter # Write hybrid ISOs to USB
    kdePackages.partitionmanager # Disk and partition management
    hardinfo2 # System benchmarks and hardware info
    wayland-utils # Wayland diagnostic tools
    wl-clipboard # Wayland copy/paste support
    vlc # Media player

    wget
    ripgrep
    git
    wezterm
    eza
    starship
    bat
    fd
    rhythmbox
    fastfetch
    ungoogled-chromium
    mpv
    cowsay
    keepassxc
    qalculate-gtk
    onlyoffice-desktopeditors
    lazydocker
    libnotify
    syncthing
    nixd
    psmisc
    playerctl
    clinfo
    pavucontrol
    gdu
    qdirstat
    mangohud
    mangojuice
    obs-studio
    nodejs
    gimp
    file-roller
    p7zip
    lmstudio
    unzip
    godot
    blender
    libheif
  ];

  services.tumbler.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  programs.nh = {
    enable = true;
    package = pkgsUnstable.nh;
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
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
  services.gvfs.enable = true;
  services.devmon.enable = true;

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

  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;

    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
