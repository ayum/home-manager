{ pkgs, inputs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
#  nixpkgs.overlays = [
#    inputs.emacs-overlay.overlays.default
#  ];
  programs.emacs = {
    enable = true;
    package = with pkgs; (emacsPackagesFor emacs).emacsWithPackages (epkgs: with epkgs; [
        vterm
        multi-vterm
        exec-path-from-shell
        treesit-grammars.with-all-grammars
        meow
        meow-tree-sitter
        key-chord
        ivy
        which-key
        hide-mode-line
        spacemacs-theme
        smex
        counsel
        treemacs
        treemacs-nerd-icons
        nerd-icons
        company
        editorconfig
      ]
    );
  };

  home.shellAliases.e = "emacsclient -c";
  home.file."${config.home.homeDirectory}/.emacs.d/init.el".source = ./emacs/init.el;
  home.file."${config.home.homeDirectory}/.emacs.d/early-init.el".source = ./emacs/early-init.el;
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    emacs-all-the-icons-fonts
    dejavu_fonts
    material-design-icons
    source-code-pro
    weather-icons
    fd
    ripgrep
    silver-searcher
    fzf
    clang-tools
  ];
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = false;
    startWithUserSession = true;
    socketActivation.enable = false;
  };
  systemd.user.services.emacs.Service.Type = lib.mkForce "exec";
  systemd.user.startServices = true;
}
