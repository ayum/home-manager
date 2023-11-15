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
        preferred = "none";
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
          RemoteCommand = ''ayum_ssh_tmpfile=$(${pkgs.coreutils}/bin/mktemp); echo "%h" >$ayum_ssh_tmpfile; IFS="." read ayum_ssh_sh remaining <$ayum_ssh_tmpfile; exec $ayum_ssh_sh'';
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
