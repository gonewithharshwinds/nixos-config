{ config, pkgs, inputs, ... }:

{
  # 1. IMPORT AGS MODULE
  imports = [ 
    ./ags/default.nix
    ./softwares/kitty.nix
    ./softwares/vscode.nix
    ./softwares/yazi.nix
    ./softwares/helix.nix
    ./hyprlandConfig/hyprlandConfig.nix
    ./custom/bento/rofi-config.nix
    ./custom/vexalis/menu.nix
  ];

  home.username = "h4rsh";
  home.homeDirectory = "/home/h4rsh";

  # Import Caelestia Shell & CLI Packages from the Flake inputs
  home.packages = [
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    
    pkgs.swww           # Wallpaper daemon for Caelestia
    pkgs.rofi           # Crawling back to the standard package because Wayland support is fully merged!
    pkgs.libnotify      # Helpful for Caelestia notifications
    pkgs.adwaita-icon-theme

    pkgs.brightnessctl  # screen brightness control
    pkgs.playerctl      # media control widgets
    pkgs.pamixer        # volume control
    
    # System libraries often required for Caelestia IPC
    pkgs.glib
    pkgs.libglvnd

    # --- NEW PACKAGES ADDED BELOW ---
    pkgs.hyprpicker
    pkgs.wl-clipboard
    pkgs.cliphist
    pkgs.inotify-tools
    pkgs.app2unit
    pkgs.trash-cli
    pkgs.foot
    pkgs.fish
    pkgs.fastfetch
    pkgs.starship
    pkgs.btop
    pkgs.helix
    pkgs.eza
    pkgs.adw-gtk3
    pkgs.papirus-icon-theme
    pkgs.grim
    pkgs.slurp
    # pkgs.kdePackages.qt5ct
    pkgs.kdePackages.qt6ct
    # Modern Nerd Font attribute
    pkgs.nerd-fonts.jetbrains-mono

    # Essential CLI upgrades because you deserve nice things
    pkgs.bat        # A better 'cat' with syntax highlighting
    pkgs.ripgrep    # A wildly faster, better 'grep'

    # The superior music client you actually wanted (renamed in 26.05 unstable)
    pkgs.pear-desktop 

    # AGS UTILITIES
    pkgs.sassc  # <--- CRITICAL ADDITION
    pkgs.dart-sass
    pkgs.fzf
    

    pkgs.libreoffice-qt
    pkgs.hunspell
    pkgs.hunspellDicts.en_US

    pkgs.vlc
    pkgs.libva
    pkgs.ffmpeg_7-full


    # Affinity V3
    inputs.affinity-nix.packages.${pkgs.stdenv.hostPlatform.system}.v3

    # Thunar with plugins
    (pkgs.thunar.override {
      thunarPlugins = [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
      ];
    })
    pkgs.tumbler 
    pkgs.gvfs

    pkgs.capacities

    (pkgs.obsidian.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })
  ];

  home.sessionVariables = {
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
  
  # Universal Cursor Theme! 
  # This stops your cursor from changing sizes or disappearing in Wayland when switching apps.
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  xdg.desktopEntries.capacities = {
    name = "Capacities";
    exec = "capacities --no-sandbox %U";
    icon = "capacities";
    terminal = false;
    type = "Application";
    categories = [ "Office" ];
  };

############################################


#########################################

  # Basic Home Manager Settings
  programs.home-manager.enable = true;

  # Allow Caelestia to manage certain XDG settings if needed
  xdg.enable = true;


#########################################

programs.direnv = {
enable = true;
nix-direnv.enable = true;
};

####################################################################
# OTHER PROGRAM ##################################
####################################################################
  # Helper configs for the new tools
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.foot.enable = true;
  programs.btop.enable = true;

  # Time-traveling to the bleeding edge!
  home.stateVersion = "26.05";
}
