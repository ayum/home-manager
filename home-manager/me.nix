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
Host *
    IdentitiesOnly no
    GSSAPIAuthentication no
Match exec="gpg-connect-agent UPDATESTARTUPTTY /bye"
Match host="!*.ayum.ru,*.*"
    Hostname %h
Match host="!*.ayum.ru,*"
    Hostname %h.ayum.ru
Match host=*.ayum.ru
    User root
    VerifyHostKeyDNS yes
Match host="!_*,*.ayum.ru"
    Tag dev
Match host=_*
    ProxyCommand nc -q0 `H="%h"; H="''${H##*_}"; echo "''$H"` %p 2>/dev/null
Match tagged=dev
    LocalCommand gpgconf --launch gpg-agent
    RequestTTY yes
Match tagged=dev !exec="[ -e ~/.ssh/master-%r@%h:%p ]"
    RemoteForward /root/.gnupg/S.gpg-agent /run/user/%i/gnupg/S.gpg-agent.extra
    RemoteForward /root/.gnupg/S.gpg-agent.ssh /run/user/%i/gnupg/S.gpg-agent.ssh
    RemoteCommand (gpg --list-keys >/dev/null 2>&1); (command -v socat >/dev/null && (socat -u OPEN:/dev/null UNIX-CONNECT:/root/.gnupg/S.gpg-agent 2>/dev/null || rm -f /root/.gnupg/S.gpg-agent; socat -u OPEN:/dev/null UNIX-CONNECT:/root/.gnupg/S.gpg-agent.ssh 2>/dev/null || rm -f /root/.gnupg/S.gpg-agent.ssh)); ent="''$(getent passwd %r)"; shell="''${ent##*:}"; exec ''$shell -l
'';
  };

  home.file.".ssh/config.d/.keep".text = "";

  ayum.secrets = {
    enable = true;
    enablePlaintextOnRest = true;
    secrets = [
      {
        path = ".ssh/config.d/work";
        mode = "600";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAV01Ms0luX2v+f+iI0f72l4gbR2i6pJoLpNa1QOIcJkIw
yVkrlGdfyv4VUaTtXes8y8GvHDQ1YrtUXC4oLTRC+W4FUFS/AYNAkkBS/eNQeNsb
0sBbART64r+W0Y643XYBFUznM/V2L+N/xDx3MIwhYJdx9i3z8MNdk/9+jdJ9AIYJ
pzYkzzjqfQgLIdWbfHDLfHv0QAOz2dSzSvgTCTq6YXSTussPbqWHykllD3MdYTdY
Ze+rTbRJav3/8vuO5IpE4QPCSIHLznUaeqGAcw4oSesa85xDzQNHOvoaFI6fDOVA
B6VrOn+tiW+W2NIm+jyAyYTcHxOJxBkklO3fLIt/R3zCAHM9F3cgfyO/0pm/12vW
3px4mvI9KWxiKr0+frVSFNybaEpilta7aDW3xUk548IMt3E+9dbu+0jzT+C0P4GN
BCCytmirL+kBxWUN5PkvddMGAv5AVc+wO4BJKDyb0SCzfYwWRFF4J02PiJ1ThQ==
=y6Xz
-----END PGP MESSAGE-----
        '';
      }
    ];
  };
}
