{
  inputs,
  lib,
  pkgs,
  hardwareConfiguration,
  ...
}: {
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    hardwareConfiguration

    ./disk-config.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
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
    };
    channel.enable = false;
  };

  networking.hostName = "dev";

  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  users.users = {
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

  environment.systemPackages = map lib.lowPrio [
  ];

  system.stateVersion = "24.04";
}
