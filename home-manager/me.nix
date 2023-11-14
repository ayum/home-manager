{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "me";
  home.homeDirectory = "/home/me";

  home.packages = [
    pkgs.yubikey-manager
  ];

  ayum.profile = {
    enable = true;
    extraLinesPrepend = ''
      unset SSH_AUTH_SOCK
    '';
  };

  services.ssh-agent.enable = false;
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    sshKeys = [
      "8AAC4E5BFF5699490FCC3671856B6E24D56AD21E"
    ];
  };

  programs.ssh = {
    enable = true;
    includes = [
      "config.d/*"
    ];
    matchBlocks = {
      "*sh.*" = {
        extraOptions = {
          RequestTTY = "force";
        };
      };
      "github.com github gh" = {
          hostname = "github.com";
          user = "git";
          identitiesOnly = false;
      };
    };
    forwardAgent = true;
    controlMaster = "yes";
    extraConfig = ''
Host *
    Hostname %h.ayum.ru
    User root
    IdentitiesOnly no
    LocalCommand gpgconf --launch gpg-agent
Match Host *.ayum.ru
    RemoteForward /root/.gnupg/S.gpg-agent /run/user/%i/gnupg/S.gpg-agent.extra
    RemoteForward /root/.gnupg/S.gpg-agent.ssh /run/user/%i/gnupg/S.gpg-agent.ssh
'';
  };

  home.file.".ssh/config.d/.keep".text = "";
}
