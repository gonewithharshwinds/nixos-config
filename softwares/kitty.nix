{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "flexoki_dark";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      # UI/UX
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0; # Disable update checks on NixOS
      
      # Window Layout
      window_padding_width = 15;
      confirm_os_window_close = 0;
    
      # Transparency (Beautification)
      background_opacity = "0.85";
      background_blur = 1; # Only works if your compositor (Hyprland) supports it
    
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
    };
  };
}