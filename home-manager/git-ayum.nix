{ pkgs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  home.file."${config.xdg.configHome}/git/user.inc".text = ''
    [user]
        email = ayum@ayum.ru
        name = ~ayum
  '';
}
