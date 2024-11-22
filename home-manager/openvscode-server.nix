{ pkgs, inputs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.openvscode-server;
  };
  ayum.secrets = {
    enable = true;
    enableSsh = true;
    secrets = [
      {
        path = "${config.home.homeDirectory}/.openvscode-server/token";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAcvfH0ZRcuV5P5bX5DxOYlmJqKb6PcsewYvRSlJ+ptSIw
B7LqubLQ2J3PprvekxikuuuxZXe15LXYteBCFZFkI9Z1/N5YK3cF8eyKvU+Puab4
0mABQlQNAfKqpOWBoqES1pOm2C1x9FOpQgIMAzk96wZM4X/KrHbIQtmi0fcGNEQE
2b65rxc6msWedMwB1e4SUwuYkwLvFCvdyYl6/o+gr5DeU+deX3gHUArs8H4nNDIC
n98=
=m9ak
-----END PGP MESSAGE-----
        '';
      }
    ];
  };
  systemd.user.services.openvscode-server = {
    Unit = {
      Description = "Openvscode server";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.openvscode-server}/bin/openvscode-server --host 127.0.0.1 --port 8080 --accept-server-license-terms --disable-telemetry --connection-token-file ${config.home.homeDirectory}/.openvscode-server/token";
      Environment = [ "PATH=/run/current-system/sw/bin/" ];
    };
  };
}
