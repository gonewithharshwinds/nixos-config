{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    
    # Enables the shell wrapper "y" which automatically changes the
    # directory when exiting yazi.
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    # enableNushellIntegration = true; # Uncomment if you use nushell

    # General configuration (yazi.toml)
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_symlink = true;
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        image_filter = "lanczos3";
        image_quality = 90;
        sixel_fraction = 15;
      };

      opener = {
        edit = [
          { run = "nvim \"$@\""; block = true; desc = "Edit"; }
        ];
        play = [
          { run = "mpv \"$@\""; orphan = true; for = "unix"; }
        ];
        open = [
          { run = "xdg-open \"$@\""; desc = "Open"; }
        ];
      };
    };

    # Keybindings (keymap.toml)
    keymap = {
      manager.prepend_keymap = [
        # Example: Drag and drop using dragon
        # { on = [ "<C-n>" ]; run = "shell 'dragon -x -i -T \"$1\"' --confirm"; desc = "Drag and drop"; }
        { on = [ "g" "n" ]; run = "cd /etc/nixos"; desc = "Go to nixos config"; }
      ];
    };

    # Visual styling (theme.toml)
    theme = {
      manager = {
        preview_hovered = { underline = true; };
      };
      status = {
        separator_open = "";
        separator_close = "";
      };
    };
  };
}