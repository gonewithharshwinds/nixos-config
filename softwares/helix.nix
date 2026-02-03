{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        indent-guides.render = true;
        auto-format = true;
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = { command = "${pkgs.lib.getExe pkgs.nixfmt-rfc-style}"; };
        }
        {
          name = "markdown";
          soft-wrap.enable = true;
          text-width = 80;
        }
      ];
    };

    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };
}