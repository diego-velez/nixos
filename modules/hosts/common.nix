{...}: {
flake.nixosModules.common = {pkgs, lib, ...}: {
    time.timeZone = lib.mkDefault "America/Puerto_Rico";

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings =  lib.mkDefault{
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

    services.xserver.enable =  lib.mkDefault true;

    services.displayManager.gdm.enable =  lib.mkDefault true;

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
        extraGroups = ["networkmanager" "wheel" "input" "uinput"];
    };

    programs.firefox.enable = lib.mkDefault true;
    programs.fish.enable = lib.mkDefault true;
    programs.niri = {
        enable = true;
        package = pkgs.niri;
    };

    nixpkgs.config.allowUnfree = lib.mkDefault true;
    nix.settings.experimental-features = lib.mkDefault ["nix-command" "flakes"];

    environment.systemPackages = with pkgs; [
        vim
        wget
        neovim
        ripgrep
        zoxide
        wezterm
        waybar
        fuzzel
        git
        eza
        atuin
        starship
    ];

    fonts.packages = with pkgs; lib.mkDefault [
        nerd-fonts.jetbrains-mono
    ];

    services.openssh.enable = lib.mkDefault true;

    system.stateVersion = lib.mkDefault "25.11";
};
}
