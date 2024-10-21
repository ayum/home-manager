{ pkgs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "me";
  home.homeDirectory = "/home/me";

  home.language = {
    base = "ru_RU.UTF-8";
    numeric ="ru_RU.UTF-8";
    time ="ru_RU.UTF-8";
    collate ="ru_RU.UTF-8";
    monetary ="ru_RU.UTF-8";
    messages ="ru_RU.UTF-8";
    paper ="ru_RU.UTF-8";
    name ="ru_RU.UTF-8";
    address ="ru_RU.UTF-8";
    telephone ="ru_RU.UTF-8";
    measurement ="ru_RU.UTF-8";
  };

  home.packages = [
    # oldpkgs.somepackage
    pkgs.yubikey-manager
    pkgs.nixos-anywhere
    pkgs.nixos-rebuild
  ];

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Inconsolata:size=10";
        box-drawings-uses-font-glyphs = "no";
        dpi-aware = "no";
        term = "xterm-256color";
        login-shell = "yes";
      };
      csd = {
        preferred = "server";
      };
      mouse = {
        alternate-scroll-mode = "yes";
      };
      key-bindings = {
        clipboard-copy = "Control+Shift+c Control+Insert XF86Copy";
        clipboard-paste = "Control+Shift+v Shift+Insert XF86Paste";
        primary-paste = "none";
        search-start = "Control+Shift+space";
      };
    };
  };

  ayum.profile = {
    enable = true;
    extraLines = (lib.optionalString (config.services.gpg-agent.enable && config.services.gpg-agent.enableSshSupport) ''
      echo $SSH_AUTH_SOCK | ${pkgs.gnugrep}/bin/grep -q 'gnupg\|gpg'; test $? -eq 0 || export SSH_AUTH_SOCK="$(${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)"
      ${config.programs.gpg.package}/bin/gpg-connect-agent updatestartuptty /bye 1>/dev/null
    '');
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
    matchBlocks = {
    };
    forwardAgent = true;
    controlMaster = "auto";
    controlPersist = "no";
    controlPath = " ~/.ssh/master-%r@%h:%p";
    extraConfig = ''
Match Host "!*.ayum.ru,*.*"
    Hostname %h
Match Host "!*.ayum.ru,*"
    Hostname %h.ayum.ru
Match Host *.ayum.ru
    User root
    IdentitiesOnly no
    LocalCommand gpgconf --launch gpg-agent
    VerifyHostKeyDNS yes
    RequestTTY yes
    RemoteForward /root/.gnupg/S.gpg-agent /run/user/%i/gnupg/S.gpg-agent.extra
    RemoteForward /root/.gnupg/S.gpg-agent.ssh /run/user/%i/gnupg/S.gpg-agent.ssh
Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
'';
  };

  home.file.".ssh/config.d/.keep".text = "";

  ayum.secrets = {
    enable = true;
    enablePlaintextOnRest = true;
    secrets = [
      {
        path = ".ssh/config.d/work";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAmzV47eeGFehykHUqvQnJOwl2Yx0usg+PfjbEbQEjAUQw
qYeb4P91iD+sKIV+0lHb3eDDzCLJ5KXfFD7YrCqtA7woKCPBD15qn7UB0cw8fdDT
0sBdASviFxsc2mbZqE4OSfQn+ciHjINvp++KYBJzV4LSAIymoRxqC1fp+rqrbPPi
b1qn4SAI3Rhevhila2lweSk5BIXfVdQquVFxR3XNrQC18gO8mC+/ZYwjJSrBypaG
Az7LL1ypyFS+XKy42Xfb1ba753Wvm5O5PS0q8X0goNVa4WZqtXqQ8Xjca2yDHduD
UP/MYdyzye1rAvjXLYVwcfqivvcDMXNBpQ71/KGhVFXar3FNDTpbgRbpc4rP6hWO
CnrQLmErmR/PfQAqgBMuVCiA/6WpRWp5sMZTQ1Bxc38jgXblMsFr2/MimcHMmn+A
4xHfQ4mmUqKoM+ni9EzD/GXykiHos/9ixzDi7mjCN1XreJqQ6UDA96age0srGj6y
=AQyr
-----END PGP MESSAGE-----
        '';
      }
    ];
  };
}
