{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = ",preferred,auto,auto";

      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$termFileManager" = "$terminal -e yazi";

      exec-once = [
        "caelestia shell -d"
        "swww-daemon"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "ags"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, Q, killactive"
        "$mainMod, M, exit"

        # Window manipulation
        "$mainMod, F, fullscreen"               # Win + F: Make current window fullscreen
        "$mainMod, SPACE, togglefloating"       # Win + Space: Float/Unfloat a window

        # Directional Focus (Like Windows Snap navigation)
        "$mainMod, left, movefocus, l"          # Win + Left Arrow
        "$mainMod, right, movefocus, r"         # Win + Right Arrow
        "$mainMod, up, movefocus, u"            # Win + Up Arrow
        "$mainMod, down, movefocus, d"          # Win + Down Arrow

        # Move windows around
        "$mainMod SHIFT, left, movewindow, l"   # Win + Shift + Left
        "$mainMod SHIFT, right, movewindow, r"  # Win + Shift + Right
        "$mainMod SHIFT, up, movewindow, u"     # Win + Shift + Up
        "$mainMod SHIFT, down, movewindow, d"   # Win + Shift + Down

        # Lock screen (Like Windows + L). Uses hyprlock from the Hypr ecosystem [1].
        "$mainMod, L, exec, hyprlock"

        # --- NEW: Remaining Fn Keys ---
      
        # F1: Music Icon (Launches the pear-desktop app you have in your home.nix)
        ", XF86AudioMedia, exec, pear-desktop"
        # F9: Email Icon (Opens terminal with an email client, or replace with thunderbird/mailspring)
        ", XF86Mail, exec, $terminal -e aerc"
        # F10: Home Icon (Opens File Manager to Home Directory)
        ", XF86Explorer, exec, $fileManager"

        # Screenshots
        "ALT, S, exec, grim - | wl-copy"
        "ALT SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        "ALT CTRL, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png"

        # Rofi launcher
        "$mainMod, G, exec, rofi -show drun"

        "$mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mainMod, RETURN, exec, $terminal"


        # --- NEW: Workspaces (Essential for Hyprland) ---
        # Switch workspaces with Win + Number
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"

        # Move active window to a workspace with Win + Shift + Number
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
      ];
      # ADD THIS BLOCK FOR THE STANDALONE WINDOWS KEY
      bindr = [
        "$mainMod, SUPER_L, exec, pkill vexalisMenu || vexalisMenu"
      ];

      bindel = [
        # F2, F3, F4: Volume Control (using pamixer)
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
      
        # F11, F12: Brightness Control (using brightnessctl)
        ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      bindl = [
        # F4: Mute
        ", XF86AudioMute, exec, pamixer -t"
        
        # F5, F6, F7, F8: Media Playback (using playerctl)
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioStop, exec, playerctl stop"
      ];
    };

    extraConfig = ''
      # 1. Suppress maximize for all windows
      windowrule = suppress_event maximize, match:class .*

      # 2. Xwayland / unmanaged window fix
      windowrule = no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0

      # 3. Kitty opacity
      windowrule = opacity 0.9 0.8, match:class ^(kitty)$

      # 4. Thunar rules
      windowrule {
        name = thunar-rules
        match:class = ^(thunar)$
        float = on
        center = on
        size = 900 600
      }

      # 5. Bento launcher rules
      windowrule {
        name = bento-launcher-rules
        match:class = ^(bento_launcher)$
        float = on
        center = on
        animation = popin 80%
        border_size = 0
        dim_around = on
      }

      # 6. Google Antigravity rules
      windowrule {
        name = google-antigravity-rules
        match:class = ^(google-antigravity)$
        workspace = 2
        opacity = 0.95 0.95
      }

      # Vexalis Menu Rules
      windowrule {
        name = vexalis-menu-rules
        match:class = ^(vexalisMenu)$
        float = on
        center = on
        # Mathematically assign the size: 
        # e.g., Width = Monitor Width minus 60px padding
        # e.g., Height = Monitor Height minus 120px padding (leaves room for the top bar!)
        size = (monitor_w - 60) (monitor_h - 120) 
        animation = popin 80%
        border_size = 0
        allows_input = on
        dim_around = on
      }
    '';
  };
}