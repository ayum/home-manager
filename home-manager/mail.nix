{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  programs.aerc = {
    enable = true;
  };
  ayum.secrets = {
    enable = true;
    enableSsh = true;
    secrets = [
      {
        path = "${config.xdg.configHome}/aerc/accounts.conf";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAuDYGoBqfluJ1Bo9C1Ik9/AvrOpFBx1zwummkR14nGyIw
djILEew75tGPPe+cGKbeoyEHYIV5NovphqmZZdrK6BV/s659gIQKKS9iz7eyA+3J
0sAQAeEOe/cat6YYTqKOj4TvMS1+hW4chiMVbQu8DYikT17uO2BTn45rzYMfNSun
wNR2ROGyFE8JfDcM216wM4laV+iUT46YHYSOXI5G+A30ywOtEVB8csEyFz0/YwKt
KN1959VnMgoMU1wB9e8np4p4BocQq0OdYc/VsMpcfe3DPWD+WKeZIfJ8fO9BUtuy
da/0xnifl2q+NJHJaryHerBCVW2/Y6msjzFfzpjTRHJukFjuWlm/0rdyg6IaDy9N
L+8gk+1qq0Wl/2tPkw8xZjaGbQ==
=ken8
-----END PGP MESSAGE-----
        '';
      }
    ];
  };
}
