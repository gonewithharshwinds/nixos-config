{ config, pkgs, ... }:

{
  # --- MODERN SYSTEM-LEVEL CONFIG (2026 STANDARDS) ---
  # Enable the ADB daemon. In NixOS, this handles the basic udev rules 
  # and the 'adbusers' group creation automatically.
  programs.adb.enable = true;

  # --- PRODUCTION HARDWARE RULES (SAMSUNG S22 OPTIMIZED) ---
  # Explicit udev rules for Samsung (Vendor ID: 04e8). 
  # This ensures the Antigravity agent can talk to your hardware 
  # without permission loops or "device unauthorized" ghosts.
  services.udev.extraRules = ''
    # Samsung Vendor ID
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers", TAG+="uaccess"
  '';

  # --- TOOLCHAIN (USER/SYSTEM SCOPE) ---
  # Modern RN CLI needs JDK 17+ and the latest platform-tools.
  # Watchman is non-negotiable for smooth file syncing.
  environment.systemPackages = with pkgs; [
    androidenv.androidPkgs.platform-tools 
    watchman                               
    jdk17                                  
    usbutils                               
  ];

  # --- PERSISTENCE ---
  # We set the environment variable that the React Native build system 
  # and the Antigravity agent will use to find your SDK assets.
  environment.variables = {
    ANDROID_HOME = "$HOME/Android/Sdk";
  };
}