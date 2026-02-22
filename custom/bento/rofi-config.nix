{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = "bento";
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "";
      drun-display-format = "{name} ({generic})";
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
}