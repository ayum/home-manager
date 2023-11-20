{ pkgs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "me";
  home.homeDirectory = "/home/me";

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
      "*sh.*" = {
        extraOptions = {
          RemoteCommand = ''ayum_ssh_tmpfile=$(${pkgs.coreutils}/bin/mktemp); echo "%h" >$ayum_ssh_tmpfile; IFS="." read ayum_ssh_sh remaining <$ayum_ssh_tmpfile; exec $ayum_ssh_sh'';
          RequestTTY = "force";
        };
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
Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
'';
  };

  home.file.".ssh/config.d/.keep".text = "";

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
      {
        path = ".cert/nm-openvpn/me-tcp-ca.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAMka1xZHJn6F9T6CvXaMpgX28Jp1EffYKErQfOrdBBmEw
6IZLMN1O/dn+eop+ZHuExVPUSMXZ7JBuYHGM/arnQHfTAQamsj5RLBx6r4X/a3DU
0ukBtISXCjF/cruHCFSa8xoEno1+vAdzwBPhMFa5U5HaGETKdA84GDzU5mimR9AJ
gJfh4OHxHf7AbhbzJBARZUGksydw9v1KQP9cPQ21SndzoETo3+iGvAHAhtKaUcTU
nX5I4sQbsTvhiq/rr+K3f/3LpolcPtRdAHu/tZnhNRJZPepRSg3xi+OvbyMWI6kM
bjS1a7mjUehzMsBJP8j0mVno+iQxfHzCHJyj7GdeeNVDUbrnR/lNwNBsJhvvGApz
+66otC64o4Y83ibvAw6uZpaCLzX8Fro1IpvIVf+4IFLSiQqRCa3RrWSLY0vm07Hh
KDdN67HmxHcDgz32uoS/vU/xL0UFQ4XTLIy0tAPiWGYna8LSmT1Qx760fn9qyBx0
sa1c075lNSiVJovqKwvoU2OgvoE17qdaJWJgpAfHUnb7W5itrmcq8HdEVFmDIMWM
f898nTyd5V6OBuOnCE8pYJm58gJdINRBcP3fmLtRfnnKJ8Ll5+jjxUE281jFwrgT
eMjhx38vbPnB/0eWgkyfBN33pCbJSKnrorDahf9YAexktMcI0Jv6JY1FbPYnq9w2
azqptBzGwO7xbndDMKGWEaonT9llxPKhSB74meH0cMv4H9OdGyTmfGOisThBUky7
6vsC8HjOyY1/KkS0fJ178C6ZCTbma5wMqv+oMFsKtvBGLE1K58lhHDV6QBpnyvzs
yfzDN8G2HVTrhlxG/s1Blmxl2qX7lZI4qqMyosN+Ioh2T47Kmfs+htW89QFK7/01
xyuD7Jh2/lWNIXBJ+tW0Dw==
=3rHY
-----END PGP MESSAGE-----
        '';
      }
      {
        path = ".cert/nm-openvpn/me-tcp-cert.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdADiY3FiVHzHpWf2nytCUPDNwpfvyGXOzPtOoiQC7aAVUw
HWhn/AFRrVqZbWyhHAYHo6g3xWMX0sSQCcII4lV1ZKyJOAq+TrCCacxwTuBx1tRZ
0ukB4W5zGLSr2rhysa4PlNp3x4BHD95Fu+WpbCJK/s2twHWfdO+mMkdSGp3+f8ey
LNU7mEAAchmvtXgw3DDR2kgkIZYfTWpu1M/1AIiez+79IAgyIn4NSuC/yxSRoNlK
+jq/fpkHI6cyyaXFZnMyYvWvC5qtlXPxal73N/qfEVv7v3JzdCVdgHXKcH4l1o4n
HmTkpNu1XMjniyxciNPb66UYqIqOq+dHu5wEf46aJpqF4BStTeSHWhO25vQEAvIe
F0k0E98+ivupW+fKiu/Rboep+9+SsL3GiV7/IeAcUUFkp8D/YiMwe0ivOfKYt+xf
ILFSsuLYPi7g+7M8MSZM2bkMKmvY1jV/NFcSdlMUgwng6Tmn/LpHKPVtnQGsvDPn
ana56edNYh1kfJjhGlyux1ICYLfO3goINEJ6FH2T9rKdPpSBj3Bxuj0A6DV+q2ht
ZrsfTRH3guPT+iNFrNSbg01dViRClKtLRmZLfF/V2nbYjFC2XF2nJYzYZ9hSwU/R
FIGXRlDjT8FF+yMhpP7kcategBim/7ThfXzDKjj9QwONsiMQ13tUdNeeXBnhZpZ8
spaiUvTEG9VTDN4qmdCgfaOaFGfO6GiiN1hlcDfZN0sPk0k1gFYv6uCn71orXqR2
ntY5g+KVxvulCr64XtpbLNaSLWLZdapsl6atbJrEtko2m2D4EAohZ5/0HZneopeO
CVn7IJGvEwX/mcRr2+ja7aymagwFo3SUPhEr/5kfOf3uaCYgKPuo8rgfDEpg8zp7
T+0HcABzPllbcUNGmMULocu+T2fsxYJiEacvl2CMsyON06o=
=zwiQ
-----END PGP MESSAGE-----
        '';
      }
      {
        path = ".cert/nm-openvpn/me-tcp-key.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAKcYK2fBZZib68WYJ9pHfs/HCdBlAIkmf+vpt2LUxGwkw
kKOoY5im/2Q5HOvaXvgZtYOblMpo03IjxsYapfLSzJFl+hNeTcJ/N/Uwe/FAZ5tY
0sBSAZvEPrzsLgbdMwlpXbsE9wMZG7ADKsboa5baCR6asdBRakdasmtBnSTanLWD
uW6taCEbdz4Zc7UDjEnubOJQcx9uYaJL9Sd4D5bfWtRq3VDFqdj+HkiOV+vAip/J
VciQs1P53M4YEGYEDe/HV5jQvGK4wnbwVlkAlw17DySQ37aWC3kRbz0AsqNqW3f9
/xyqefitJpJ6G5mev0+ped5Cya5QZ+RgS1rOx4fhXOpUcbjYNcKTLwXs/exzALSB
O8+TaJiR3e4oaO6/sPARtVkMziK5o+NwYJHvYlX89CKoGjY9MGP+EjEdKu0wL1Ec
o+gUrjOpAEsqRmYyKUYsZErP81goL5Y7JluieZlJSWpH1buLRw==
=JmjX
-----END PGP MESSAGE-----
        '';
      }
      {
        path = ".cert/nm-openvpn/me-tcp-tls-crypt.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAFV5aJLdyYpU47KRc1PqLObHVZZN+PHMLdz5KMrUYBXMw
Hz4qQTXR2zu5y6T2qJkGd+mCOeoAW4yIF8FDPBmgqafCKbXOmbPdtdI8ClJYUYds
0sEWAX9kGP3qKHMHWyTFcRWVoVsMNqUeULmklskBCCa2/4d9WFQAys/axQCWzuUM
Ej8rrkt0FVrdOLT14Aj9CUPOKcDHdRdp6WaTL43DXobQEFbtIc4Thxv5w0hZwj0c
z2Gp7ahVXjRM+KLoLiH/+K9Me3dMtrzaGqwKl0zvJIB1A2tLngQW0rMkFIC2phTO
H0AIBYCs50h5BNyWTl/MfG+ebp4MqNJ4EvnOry5fGPYtwuRq9zcQq1dyIhyysOyA
9B5ooseGrdvPGdNjuNOZwH59F7UXbmV4v++owp+ukLvweDe1HghqO/0S/bjl/uZy
WTGMiiauImgvXOpaHVILeK4tRAawNqHvYp/jG9XHiDp8n/cRlLJCv6PBaY/hhy+W
6MTvad4MzSyFYO7TIqET3KYqP/+3wHwT7w0lp9SUMyVa/7JFgRnrtCqPLqAOUDaE
XiFpUucrVRMP7V1vltwc5kwuuS4ms41GwHXc4sV9tiZD874CW2j7E7bKo4DFZwZg
CY9vJxPOB4AJRHvpWkTdtM3YzI+zEhkukI9g1G/maYcKnC98dESoIZVWV+zq6yKR
KCjfREqpNbif+EU5ZDFLxzaXWUyjwmfO31D/ELiOi0G6ElMy/Io6R+I=
=i6iy
-----END PGP MESSAGE-----
        '';
      }
      {
        path = ".cert/nm-openvpn/me-udp-ca.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAgMR2EqBmlmq/nTD+gdEUbK0B+P6VS58GrQD3wxrMRGIw
thrh6d12mSsbRAgjP6jYngAzBjDugpRdqVUzDYeNR2Q7mcnD9zsoLiYl3VghP0ir
0ukBFf2chqWQQ0ox8yp2xxeWFSJxADNdB/rEkoDgw/UreHQopBLM+Jhm8T+qV4PB
+qpCjlp9MPHgidSvwPrcnz2mZOHhhcWlpMzg7mss1eMVB6MSC8GI64Oct7BJMuxJ
ey8JSsKY3IGRasIXunYO5p/56oI+HpcWqAYuWbM5VLh4qRNyqiDiU5Hzf9AdsUZ7
u7GTQNOvAqS+XUoOAu9DizM/IE68rEz4P1fdjNIadzKeWPXWqBHOCefU8Qw3Drar
8qYYjr0w8ojMEgRSG7qOQxXxvqairfKVDAxDoxr6ZNdMVOXQF6HKZxUCec4KkjlF
m/jM95I83lnuysUSG5gD8F63cBzjcP1Dq2H+tSAFLN56yjlSpK6kb2KxcQH+9AWL
yiFMpVdS51a+0si/CZ+b/wkkSxjxnv2gsneAino8N7nVD6aIYUctERLdbnUel0rK
NmymTPEUhZFPQlP2Gb8kWlEHs11BTkEtQky12bOAJOc2w3/cCiqupJU1L5a95LAr
yvW8X7QkYQ1fuGyiRu5dF+slUtzPhjuM0/eP/Mkd14jHh5yVUoE2eZVEc9gdpV6x
ApUQ3jL5E+KU+GnXNOo3mnkTX4LaQMl0c2rLqbghEQr4vMopa76t9LsJXJYeAA2D
3KI92SNQbIgenRzAjfUcYrOgIZXnuxyaeBiMJPjGOcq+Ak2G4iWSKz3MIJOgHil3
S3CypEteRkwWE60GNubxN6+2b5Hp5kpXL5QVuKGlsb3H3ObxSoj8M/LZ2zbiox10
PKfgxgiA3/6LdWdnAMhJEA==
=6RZN
-----END PGP MESSAGE-----
        '';
      }
      {
        path = ".cert/nm-openvpn/me-udp-cert.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAtRvVFw1TeragJPOtlBpJmrMx+U2/Gs64z2I6p32uU2Ew
PhL+jxdy091zeVzGcSKxeKYGOy4wFbeNuHvGK16UrH5ObRFqzamHX3i2wAl38WML
0ukBQTcdDStMvxw4Wn/sS7+l17WDfJyC0Yec8dAxssQ1dUEcuNbTUx3rfOoZtbqd
zaDaR+n1VMT/+l2yPIqU9Tukl8yQIUe45mnv0dOuuGoImg7ZjyBnHhJdfVl00b7M
GOFwSdLaQYnZ4Js9OeCVZg4GzRleqtaCmh/mNEuy4FUHOe3fP39V82R2IX9pCozy
qQSzTqogrexuleK+mu1EhaWyOxIAaaeV90/erSFUYkwVY+JGk1VRvMjOrJwBpbMO
shRk+4aKfquEIRcnGj6EXVQlHmqG9r1jBZZrGS7ZW1x7Z9OCyoe878gQOzNTj/VW
4GHRnfqMNe1ZmFX7Lb3Zf0ADV7VgxeilpJJLdgovSahSNJsJ+3KPfJQ95bohdEdF
iSEm6diyePl5Zs9lynE1mEcZz1k4nsEts0CC05qA30c9I+DiFeGsETy98RQoexqu
pMw3qkAwPLjjsM6GVJrcRh90bfd2RqgBsrsmjT4naEqiWfGkTAFtL8Ar2n8vVAT2
pG7bI2rISKpnQ/cb2AOn3vM9kQEhO1iIBqS/Xqc4mLKDt6USrM2j36v/qzXze8wU
KkEZMvYvah4JEJ7JMPi5njuPwMnAeFZu4TplUdE92UKM0k2KVEXQ7ZKOpKa7dY0H
OlAQDuFSncOWE/IAMTVYo9gKiTB+eTPJWRHUODEga20/kmCxqLJjLa8mjbghKIMp
mj6JbOalP5i0zUeC0ar9+dQD4oeaQ3ZW9gtrARVBBUEqPk5AYjazkHntzYeukQep
vthocAQYU5L1rKtu+xUzcpcwcQSKbCaJraxC5xnwNZoygsQ=
=dVFn
-----END PGP MESSAGE-----
       '';
      }
      {
        path = ".cert/nm-openvpn/me-udp-key.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAbLBavp0YJlwDpTYanl0GYcxTcZq7yUptLpoiEm99kXUw
LoanDcWZELARRUWW0YviXJcWVCAz5W5MFnhEGtvhVWMgDo7HeN8HDEZ+Ptjfytoj
0sBSAYS57wlwogf8avFZOEJnyHZxxwkM4MjSlmfHd83QdHlxtpevQdZwllxy96Jc
2OGWWN5bfveD8h9pPLelQzj9/bPAFk1XxF1S2zDGf65SaDrOSIScBQfGleAhtp4f
1aKubTXQYqkMJGcaKaHzVs63Lj9iQg0DOfcB2qUP5CqFJxRPOK/Ng2AwuG/IonVT
sKCAHDuV3Ifh9Gfw2KlXp/jWsWK6YgOkpDk3vShuznmUnuYmdTWYZRmpUHZDYHFz
wDxQ8fvPlkc+cA2HbqkIwC2utM4zaFvdBhQqNj5BxzvOQthNBgzrgPsfFJ7xMim/
mcLy91YMDPbYFNhsfgYNR4Ujw/ruW/V9V9k82jyDBQC2Uvo/2A==
=B8Fe
-----END PGP MESSAGE-----
        '';
      }
      {
        path = ".cert/nm-openvpn/me-udp-tls-crypt.pem";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hF4Dspzg4We8e9wSAQdAL/bRoU2bWMSBUOxBgtZoCuTy1M5XGFWOhCKjEQl4PC8w
WUurLc/TJmS+gOzj6Vq+BfgQmqzG/3F3njD1pkA0aZZBnAXQIx8Bdwn7lJl+8QBG
0sEWARTaNmwFpRculCcj9VAgD7/ozKPkgBfu4g8rbQWJM50a8AVDnn+03eHETorj
dIOkpL41ir6xFsSbkab3qs5nxzi10t4apkE5dlAgGdpVLEx3tNdw16iy+hHHFhY3
GtqWGTyi4nFWlY40NOJy5U42GmjsG4J6W9NtxZH1HFF2eFJjPHN/gNIyDbfj/aGR
PqlmUj27p5JwKOxXZpjlIkmUjxs4UPzpdYOo+vIqWWZMd51T53h4Uxv7dsdzaWTi
oYYxVlf4vuUHITUh+GZDymtXrb6aLLolR4CFWaz6hnPhhKkrHGi0CcG04pl9bHti
CmV3uQYETx37q6weZta7Q3VQDRhAhkbwWQm458ETmZZZOIL/pbNquM8eizNJmuBD
PmwjPfj6G5QZGWjUIF/qcf5NZLgfNshWltAKFYgt/EkdibcRrGlkaHWQbNM54WyL
YW8DGfeSNdWyWXK9sRSvAoOOjkdxyWT/oadjzIVpq9g/9V9umW5ltIQUk805D0Yt
/uX3/2XN2+Yy83tnqF3HLQUSyoCieZs6oqXbkUEPuv+5uD76HjtOxS+l11j1FRNx
o9/Cf6N0mEuNM8fGit6qdijPwHL81/t88cTsqQaIaR44akZOFVtEmxA=
=tWtc
-----END PGP MESSAGE-----
        '';
      }
    ];
  };
}
