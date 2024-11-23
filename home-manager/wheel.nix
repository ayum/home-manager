{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "wheel";
  home.homeDirectory = "/home/wheel";

  ayum.secrets = {
    enable = true;
    enableSsh = true;
    enablePlaintextOnRest = true;
    secrets = [
      {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdASehKMKA+/3iaP66xQQbiuiVBqfcr/YUP62dYpTGYaScw
R4x+2Ua6XfBA23LKm1VGdwps64/5LnUBipNGS+QYYXXSQ1YOScDEevrQL2Oe2DX+
0sCaAbyU+0O44JeB5NG0id56RiaUzx8+MmZS8mWw7u+rZP8ZYUIZxuGk6xUI09yL
aH2mov79khjsaJaJ8tUta2RyH8OVFrF1BEfgz5PinsugP918Ek8yJFwH2r519z2B
1jUiPEX5lLpiaffxbyhgLiKcMLLu1jLSqd29SKXTWRL2tuwDdGyVluo4vC37B7s6
5Vu+44tHfkfS8qpdNENjiEalvhU+i08AHZFsYUnQgnzRdL/I47AhXseoE/63ly/T
Z/FtFb2Rm+lzlyWk37e4hL+74XoVXujA+P7wAob+L94MyE6GGh/CDDCkCK5E7QrS
Z+TwyQbaw/BLUph5JNWUsOiqggiLbPi5TwmbnPCkHnztHrahCrcnbl+9HqwYvE7C
4MevrRDCS6CuFMic2AXj4082w9DS0axv0q+oLVu5S6UwK7ZN8wEhRuqKHWZjsdYe
FWXWKYzRE1z68PhrKQ==
=WO/X
-----END PGP MESSAGE-----
        '';
        mode = "600";
      }
    ];
  };
}
