{ pkgs, ... }:

pkgs.appimageTools.wrapType2 {
  name = "capacities";
  src = pkgs.fetchurl {
    url = "https://github.com/capacitiesio/capacities-desktop/releases/latest/download/Capacities-x86_64.AppImage";
    # You'll need to update this hash or use lib.fakeHash initially
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; 
  };
  extraPkgs = pkgs: with pkgs; [ 
    libsecret 
    nss 
    atk 
    at-spi2-atk 
    cups 
    libdrm 
    mesa 
    alsa-lib 
  ];
}