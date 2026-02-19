{ config, pkgs, ... }:

{
  # SYSTEM LEVEL - This MUST stay in system config, not Home Manager
  programs.adb.enable = true;

  services.udev.extraRules = ''
    # Samsung Vendor ID (S22)
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    watchman                               
    jdk17                                  
    usbutils # This provides the 'lsusb' command you were missing!
  ];

  environment.variables = {
  };
}