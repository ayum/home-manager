{ pkgs, inputs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];
  programs.emacs = {
    enable = true;
    package = with pkgs; (emacsPackagesFor emacs-unstable).emacsWithPackages (epkgs: with epkgs; [
        vterm
        treesit-grammars.with-all-grammars
      ]
    );
  };
  home.file."${config.xdg.configHome}/emacs".source = inputs.doomemacs;
  home.file."${config.xdg.configHome}/doom/config.el".source = ./doom/config.el;
  home.file."${config.xdg.configHome}/doom/init.el".source = ./doom/init.el; 
  home.file."${config.xdg.configHome}/doom/packages.el".source = ./doom/packages.el;
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    emacs-all-the-icons-fonts
    dejavu_fonts
    material-design-icons
    source-code-pro
    weather-icons
    fd
    ripgrep
  ];
  home.sessionVariables = {
    EMACSDIR = "${config.xdg.configHome}/emacs";
    DOOMDIR = "${config.xdg.configHome}/doom";
    DOOMLOCALDIR = "${config.xdg.cacheHome}/doom-emacs";
  };
  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];
#  services.emacs = {
#    enable = true;
#    startWithUserSession = true;
#    socketActivation.enable = false;
#  };
}
