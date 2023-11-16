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
    extraLines = (lib.optionalString (config.services.gpg-agent.enable && config.services.gpg-agent.enableSshSupport) ''
      echo $SSH_AUTH_SOCK | ${pkgs.gnugrep}/bin/grep -q 'gnupg\|gpg'; test $? -eq 0 || export SSH_AUTH_SOCK="$(${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)"
    '');
  };

  ayum.secrets = {
    enable = true;
    enablePlaintextOnRest = true;
    secrets = [
      {
        path = ".ssh/config.d/work";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdACtjoL5LrrEU6VCIJBcWy/n5OwrFiFTOpzNWr2qX7iT8w
KPTo36oAJ+1bg2/J9JNqkuXPlcDHfx5bc3+LHPZXfJhuOu3aD4oyFKD6PgJllJ1X
0q0B8+8XkiGvdVMXyOh0qQ3Q7pk5aNYOUcuYRDPSZZ992SDgcyX7bRPTqOyGGWOf
4ibsytQjo3Z5grEKbP+2GqVTbN0IKcntwo/JmH30hXqpUBB0p2nr4j4ubDL6JOPk
SQaSxXdzckIAZCbe6qE6aCfDBMj/LwJ+5mBTdkNuG+x91Y0PWt/+AwAmvonUY4Oh
lkF+199m5on+DpBgn1+LSwv9maDDYntWH8bcOvinWw==
=G5Mu
-----END PGP MESSAGE-----
        '';
      }
    ];
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
    controlMaster = "auto";
    controlPersist = "yes";
    extraConfig = ''
Host *
    Hostname %h.ayum.ru
    User root
    IdentitiesOnly no
    LocalCommand gpgconf --launch gpg-agent
Match Host *.ayum.ru
    VerifyHostKeyDNS yes
    RemoteForward /root/.gnupg/S.gpg-agent /run/user/%i/gnupg/S.gpg-agent.extra
    RemoteForward /root/.gnupg/S.gpg-agent.ssh /run/user/%i/gnupg/S.gpg-agent.ssh
'';
  };

  home.file.".ssh/config.d/.keep".text = "";
}
