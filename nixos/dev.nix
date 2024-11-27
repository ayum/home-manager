{
  inputs,
  lib,
  pkgs,
  hardwareConfiguration,
  ...
}: {
  imports = [
    hardwareConfiguration
  ];

  nixpkgs = {
    overlays = [ ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      auto-optimise-store = true;
      extra-nix-path = "nixpkgs=flake:nixpkgs";
      trusted-users = [ "@root" "@wheel" "@sudo" "@adm" "@admin" ];
      substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" "https://ayum.cachix.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "ayum.cachix.org-1:LuR7eVuXPJK7PwgbmnvNQOp2FQ9TLTToyOVON8fpk3E=" ];
    };
    channel.enable = false;
  };

  networking.hostName = "dev";
  networking.domain = "ayum.ru";

  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  users.enforceIdUniqueness = false;
  users.users = {
    wheel = {
      uid = 1;
      group = "root";
      home = "/home/wheel";
      createHome = true;
      useDefaultShell = true;
      initialPassword = "wheel";
      initialHashedPassword = null;
      isNormalUser = false;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBYiRMp0kc8LEOAhaEkI7XwGRhqdUS2radGD6jNhZFT openpgp:0x79C95C07"
      ];
      extraGroups = [ "wheel" ];
      linger = true;
    };
    root = {
      initialPassword = "root";
      initialHashedPassword = null;
      isNormalUser = false;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBYiRMp0kc8LEOAhaEkI7XwGRhqdUS2radGD6jNhZFT openpgp:0x79C95C07"
      ];
      extraGroups = [ ];
      linger = true;
    };
  };
  security.sudo.extraRules = [
    { groups = [ "wheel" ]; commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ]; }
  ];

  i18n.defaultLocale = "ru_RU.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  services.qemuGuest.enable = true;

  systemd.user.services."gpgconf-create-socketdir" = {
    description = "Create gpg socketdir upon login";

    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.gnupg}/bin/gpgconf --create-socketdir";
    };

    wantedBy = [ "default.target" ];
  };

  environment = {
    etc."inputrc".text = ''
# inputrc borrowed from CentOS (RHEL).

set bell-style none

set meta-flag on
set input-meta on
set convert-meta off
set output-meta on
set colored-stats on

#set mark-symlinked-directories on

$if mode=emacs

# for linux console and RH/Debian xterm
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert
"\e[5C": forward-word
"\e[5D": backward-word
"\e[1;5C": forward-word
"\e[1;5D": backward-word

# for rxvt
"\e[8~": end-of-line

# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for freebsd console
"\e[H": beginning-of-line
"\e[F": end-of-line
$endif

# appended after end of default inputrc  
set completion-ignore-case On
'';

  systemPackages = map lib.lowPrio [
       pkgs.ppp
    ];
  };

  system.stateVersion = "24.04";

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "ayum@ayum.ru";
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."dev.ayum.ru" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig =
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };
  };
}
