{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "wheel";
  home.homeDirectory = "/home/wheel";
}
