{ pkgs, ... }:

{
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
}