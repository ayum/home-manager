# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  pkgs,
  np,
  hardwareConfiguration,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    hardwareConfiguration

    ./disk-config.nix
  ];

  nixpkgs = {
    # You can add overlays here
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
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    #nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
        "ca-derivations"
      ];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      extra-nix-path = "nixpkgs=flake:nixpkgs";
    };
  };

  # FIXME: Add the rest of your current configuration

  # TODO: Set your hostname
  networking.hostName = "dev";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    root = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "root";
      isNormalUser = false;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCrj0ZAmSk1AK/1uHD07sDZKz8EAHPlcq54NVD7A/QjrxHNc6Re7n59DmZ+duLXo40MRT+iz9m1uoynu+TXYV6jBnA9y2sjDmUhNg5hbY1o0y7fh+HXye8qIg1Y6rxi36q8amFv3ywT5RXqP6fN7L3QZnAx9i4fQMhVGkACwxLC+QmeEXgVapPcMIh2j/J460pbfCXKCBiZfLxsT6DCd3MO+YWAvKdo5FgS3tih4qXprPl4HomcHbG+Fh5I61uHY37lwd/qcZZvTMWlZsCdf1A92zy8UvqsZIoiLtngIfbAryN0wZcE31tMZ3uAvvopBgCrt6ZdfXumrdsJn0Nc32L @home"
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ ];
      linger = true;
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "yes";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  services.qemuGuest.enable = true;
  # services.zabbixAgent.enable = true;

  systemd.user.services."gpgconf-create-socketdir" = {
    description = "Create gpg socketdir upon login";

    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.gnupg}/bin/gpgconf --create-socketdir";
    };

    wantedBy = [ "default.target" ];
  };

  environment.systemPackages = map lib.lowPrio [
    # pkgs.curl
    # np.curl
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
