{ inputs, pkgs, ... }:

{
  # Import the AGS Home Manager module from flake inputs
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = with pkgs; [
    # AGS DEPENDENCIES
    sassc
    dart-sass
    fd
    fzf
    material-symbols
    gtksourceview
    webkitgtk_4_1
    accountsservice
  ];

  programs.ags = {
    enable = true;

    # CRITICAL: This points to the 'config' FOLDER inside the 'ags' directory
    # containing this file.
    configDir = ./config; 
    
    # Extra packages available to the GJS environment
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_4_1
      accountsservice
    ];
  };
}