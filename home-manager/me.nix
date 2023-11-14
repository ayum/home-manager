{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "me";
  home.homeDirectory = "/home/me";

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
  };

  programs.ssh = {
    enable = true;
    includes = [
      "config.d/*"
    ];
    matchBlocks = {
      "dev" = {
        extraOptions = {
          RequestTTY = "force";
          RemoteCommand  = "zsh -l";
        };
      };
    };
    forwardAgent = true;
    controlMaster = "yes";
    extraConfig = ''
      Host *
          User root
          IdentityFile ~/.ssh/id_rsa
          RemoteForward /root/.gnupg/S.gpg-agent /run/user/%i/gnupg/S.gpg-agent.extra
          LocalCommand gpgconf --launch gpg-agent
    ''; 
  };
}
