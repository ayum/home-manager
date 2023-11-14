{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";
}
