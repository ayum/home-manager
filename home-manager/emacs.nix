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

  home.file."${config.xdg.configHome}/emacs" = {
    recursive = true;
    source = inputs.spacemacs;
  };
  home.file."${config.xdg.configHome}/spacemacs/init.el".source = ./spacemacs/init.el;
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
    SPACEMACSDIR = "${config.xdg.configHome}/spacemacs";
  };
  services.emacs = {
    enable = true;
    startWithUserSession = true;
    socketActivation.enable = false;
  };
#  home.activation.spacemacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
#    if ! [ -d "${config.xdg.configHome}/emacs" ]; then
#      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${config.xdg.configHome}/emacs"
#      $DRY_RUN_CMD cd "${config.xdg.configHome}/emacs"
#      $DRY_RUN_CMD ${lib.getExe pkgs.git} init
#      $DRY_RUN_CMD ${lib.getExe pkgs.git} remote add origin "https://github.com/syl20bnr/spacemacs.git"
#      $DRY_RUN_CMD ${lib.getExe pkgs.git} fetch --depth=1 origin ${inputs.spacemacs.rev}
#      $DRY_RUN_CMD ${lib.getExe pkgs.git} reset --hard FETCH_HEAD
#    fi
#  '';
}
