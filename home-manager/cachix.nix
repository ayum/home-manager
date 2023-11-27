{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  home.packages = [
    pkgs.cachix
  ];
  ayum.secrets = {
    enable = true;
    enableSsh = true;
    secrets = [
      {
        path = "${config.xdg.configHome}/cachix/cachix.dhall";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdA3EWSLxDsqyfKW0xiOMKOqJ4bxJh5w+oryDwu1/Iw9Dow
1jjXPzFU145DECS4PnwI0cykRg3i1UAqwfLYDkTRr2VnjivEv8QyzrZvl+R9HjOw
0sBqARhiY/3nX8LBDUSvoLG2cMiPQmHneY6XecxWEXQFh41o4TH1OWUlx5+UNUgx
yKHNN+wWa1aN7jkx+Q9IBC2I+KF4wDP/kbtLoeW8L1iF+SlxGOTQa4bbjd8FzQRJ
pg2wET74GZGgA8RoYhMhtLR+lpW/2jbu0k2aawX4YAcdLNCGu2TEt1xh5AQCull/
n/g/7R9fPVkBhdzyyWO7mYghkv9a+ReoP2QKZ11MLCanNnYesxANe9M89EzRX/1p
y5/bNGsjvbrkjQbkpGVSHlp00ufhqENfM7upf/JFQSDgL+CzlOboY/H8vEfV745J
M1m4Pe71GIJc+z+cuk7sPFZz3PPq/a2wRpRt9859Zbsm9OolvTxvRh8fmAC9QaxY
ccaq8DL0z2u67o0i6w==
=Z/eD
-----END PGP MESSAGE-----
        '';
      }
    ];
  };
}
