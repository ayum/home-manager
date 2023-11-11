{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  programs.aerc = {
    enable = true;
  };
  ayum.secrets = {
    enable = true;
    secrets = [
      {
        path = "${config.xdg.configHome}/aerc/accounts.conf";
        ciphertext = ''
-----BEGIN PGP MESSAGE-----

hQIOA8EMv8YRtwRlEAf+OBL38onaSa64CuHznE/2XDQ4oHWbusWx0zluBzDhGx41
E4U/r+/40FJDWHfujUMPr3C2i2Ka3EVztJeBtlloYzZMsfjGRxkWLgsxosPyDjGo
yRAqXP+JaZWZaUk/4OkPAFU1EAyx1s0nNagF6bMKD0iLLXNZphzCKf+sT7//2JCy
XWR0Tv7vNm1GC47wiJ1SU/ghMt7aN+pjSmpCDFdE63ofBQx0uVzOQC6Ln3u39bLq
H8YuiZeDHECmY8QpPEeJPmjTetvxRBr3SqJ55DW2Z8kHiFvqds1E0m0shROuUgzE
uTL7EdGWEdAyQemtFMSeVOL65u+YHAaz5WW+19xHiwf/VOcfj+l7ZTxh1TkxWbQ2
YnuIgDVeyU/2Gn13DpOddUKFWHRjdQWyzpyK0drOTEjV5Sdhofp78Rwh13JjeEOj
ln3EJsklLDj+4+oRk10B5seJ5hJp1G9Uc7j/RYfm/VlNpeuGa862tRDn0j3UqjoF
0eyRPAl0D10qhRNjWnWOWplzvc7hJHh942Bcd8Nc7Kop6lI9lbNF9oeaRqtJZ69R
84bqzi7DNGk+DUsfuI91mNfo4JR506e+BTJrtSyTIMoknRvejR0h3gNVd7A9RZpS
RE1K1WaQg/mTH+w8Ui5BArgjqPlH4V/kbTwOq2HiH4Rb3sZXxZIPECIBOb1wPgOY
vNLAEQGdX5D4Jy1HLhIWB0uZ8pTC9qwvzXpnXOzXc5qcax0HnLERo/tPJDoi9QXJ
O+160r4LsKpgIFrg0ZOOMBxBlxS5DLeQx9Fe2NiyFn/ARtmf3RGfB79mTX24saNE
jCDRq/7XxFw3xtAu9JAP/Ivt1SwIc2DAOvSH5x6EtO/pnUqq2YMHgnx19ftBL1h7
EdeCfcBAYzPuKXJSe5ZkXugVXCCY77bc7u6w03ykMAI7tb72lHXkNd5EwtQ7AGaC
cR7LCN1veXURs04LhGh0BbcqgwYS
=EbV1
-----END PGP MESSAGE-----
        '';        
      }
    ];
  };
}
