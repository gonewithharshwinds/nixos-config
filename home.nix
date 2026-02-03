{ config, pkgs, inputs, ... }:

{
  # 1. IMPORT AGS MODULE (CRITICAL ADDITION)
  # imports = [ inputs.ags.homeManagerModules.default ];

  imports = [ 
    ./ags/default.nix 
    ./softwares/kitty.nix
    #./softwares/vscode.nix
    ./softwares/yazi.nix
    ./softwares/helix.nix
  ];

  home.username = "h4rsh";
  home.homeDirectory = "/home/h4rsh";

  # Import Caelestia Shell & CLI Packages from the Flake inputs
  home.packages = [
    inputs.caelestia-shell.packages.${pkgs.system}.default
    inputs.caelestia-cli.packages.${pkgs.system}.default
    inputs.antigravity-nix.packages.${pkgs.system}.default
    
    pkgs.swww           # Wallpaper daemon for Caelestia
    pkgs.rofi           # FIXED: 'rofi-wayland' is now merged into 'rofi'
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
    inputs.affinity-nix.packages.${pkgs.system}.v3

    # Thunar with plugins
    (pkgs.thunar.override {
      thunarPlugins = [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
      ];
    })
    pkgs.tumbler 
    pkgs.gvfs

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

  # 3. AGS CONFIGURATION (Replaces Rofi eventually)
  #programs.ags = {
  #  enable = true;
  #  configDir = ./ags; # This assumes you create the folder ~/.config/ags or next to this file
  #  extraPackages = with pkgs; [
  #    gtksourceview
  #    webkitgtk_4_1 # FIXED: Updated from 'webkitgtk' to explicit ABI version
  #    accountsservice
  #  ];
  #};

############################################

# Kept your Rofi config as backup/alternative
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = "bento";
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "";
      drun-display-format = "{name} <span size='small' weight='light' alpha='50%'>({generic})</span>";
      sidebar-mode = false;
    };
  };

xdg.configFile."rofi/bento.rasi".text = ''
  * {
      bg: #fdf7ff;
      bg-alt: #f3edf7;
      fg: #1d1b20;
      primary: #6750a4;
      on-primary: #ffffff;
      accent: #eaddff;
      font: "Roboto Flex 11";
      background-color: transparent;
  }
  window {
      fullscreen: true;
      background-color: @bg;
      padding: 35% 10%; 
      anchor: center;
      location: center;
  }
  mainbox {
      children: [ inputbar, listview ];
      spacing: 40px;
      orientation: vertical;
  }
  inputbar {
      background-color: @bg-alt;
      text-color: @fg;
      border-radius: 999px;
      margin: 0px 30%;
      padding: 12px 24px;
      children: [ entry ];
  }
  entry {
      placeholder: "Search...";
      placeholder-color: #79747e;
      horizontal-align: 0.5;
  }
  listview {
      layout: horizontal;
      spacing: 15px;
      lines: 100;
      columns: 1;
      cycle: true;
      fixed-height: true;
  }
  element {
      orientation: vertical;
      padding: 25px 15px;
      border-radius: 24px;
      background-color: @bg-alt;
      cursor: pointer;
      width: 140px; 
  }
  element selected {
      background-color: @primary;
      border: 2px;
      border-color: @accent;
  }
  element selected element-text {
      text-color: @on-primary;
  }
  element-icon {
      size: 64px;
      horizontal-align: 0.5;
      padding: 0 0 10px 0;
  }
  element-text {
      text-color: @fg;
      horizontal-align: 0.5;
      vertical-align: 0.5;
      markup: true;
  }
  '';
#########################################

  # Basic Home Manager Settings
  programs.home-manager.enable = true;

  # Allow Caelestia to manage certain XDG settings if needed
  xdg.enable = true;

    wayland.windowManager.hyprland = {
    enable = true;
    settings = {
        monitor = ",preferred, auto, auto";
  
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
        "$termFileManager" = "$terminal -e yazi";
        
        exec-once = [
          "caelestia shell -d"
          "swww-daemon"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "ags" # Starts the daemon (config loaded from ags/default.nix)
        ];
  
        general  = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
        };
  
        bind = [
          "$mainMod, T, exec, $terminal"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, Q, killactive"
          "$mainMod, M, exit"

          # Screenshots
          "ALT, S, exec, grim - | wl-copy" # whole area
          "ALT SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy" # select area
          "ALT CTRL, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png" # auto save

          # --- AGS LAUNCHER BINDING ---
          # This triggers the 'bento_launcher' window defined in your JS config
          "$mainMod, G, exec, ags -t bento_launcher"

          "SUPER, SUPER_L, global, caelestia:launcher"
          "SUPER, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
          "SUPER, E, exec, thunar"
          "SUPER, Q, exec, kitty"
        ];

        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "nofocus, class:^$, title:^$"
          "opacity 0.9 0.8, class:^(kitty)$"
          "float, class:^(thunar)$"
          "center, class:^(thunar)$"
          "size 900 600, class:^(thunar)$"
          
          # --- BENTO LAUNCHER RULES ---
          # These rules apply to the AGS window named 'bento_launcher'
          "float, class:^(bento_launcher)$"
          "center, class:^(bento_launcher)$"
          "animation popin 80%, class:^(bento_launcher)$"
          "noborder, class:^(bento_launcher)$"
          "dimaround, class:^(bento_launcher)$"

          "workspace 2, class:^(google-antigravity)$"
          "opacity 0.95 0.95, class:^(google-antigravity)$"
        ];
  
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };
    };
  };

programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      jnoortheen.nix-ide
      mkhl.direnv
    ];
    userSettings = {
      "window.titleBarStyle" = "custom";
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace', monospace";
      "editor.fontSize" = 13;
      "editor.fontLigatures" = true;
      "workbench.colorTheme" = "Catppuccin Mocha"; # Switched to Catppuccin as it's standard in nixpkgs
      "workbench.iconTheme" = "catppuccin-mocha";
      "editor.minimap.enabled" = false;
      "editor.scrollbar.vertical" = "hidden";
      "editor.scrollbar.horizontal" = "hidden";
      "window.menuBarVisibility" = "toggle";
      "workbench.activityBar.location" = "top";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.smoothScrolling" = true;
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
    };
  };


programs.direnv = {
enable = true;
nix-direnv.enable = true;
# These are now enabled by default; explicitly setting them to true
# was causing "read-only" errors in recent Home Manager versions.
};

####################################################################
# OTHER PROGRAM ##################################
####################################################################
  # Helper configs for the new tools
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.foot.enable = true;
  programs.btop.enable = true;

  home.stateVersion = "25.11";
}
