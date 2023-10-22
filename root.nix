{ pkgs, home-manager, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "root";
  home.homeDirectory = "/root";
  home.language = {
    base = "ru_RU.UTF-8";
    ctype ="C.UTF-8";
    numeric ="ru_RU.UTF-8";
    time ="ru_RU.UTF-8";
    collate ="ru_RU.UTF-8";
    monetary ="ru_RU.UTF-8";
    messages ="ru_RU.UTF-8";
    paper ="ru_RU.UTF-8";
    name ="ru_RU.UTF-8";
    address ="ru_RU.UTF-8";
    telephone ="ru_RU.UTF-8";
    measurement ="ru_RU.UTF-8";
  };

  # Packages that should be installed to the user profile.
  home.packages = [
    pkgs.clang-tools_16
    pkgs.kak-lsp
    pkgs.editorconfig-core-c
    pkgs.mc
    pkgs.tig
    pkgs.curl
    pkgs.wget
    pkgs.htop
    pkgs.iotop
    pkgs.zip
    pkgs.unzip
    pkgs.silver-searcher
    pkgs.fzf
  ];

  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

#  xdg.configFile = {
#    "home-manager".source = self;
#  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initExtra = ''
      unsetopt share_history
      setopt inc_append_history
    '';
    shellAliases = {
      tmu = "tmux new -As0";
    };
  };

  programs.tmux = {
    enable = true;
    historyLimit = 12345678;
    extraConfig = ''
      set -sg escape-time 25
    '';
  };

  programs.kakoune = {
    enable = true;
    defaultEditor = true;
    plugins = [ pkgs.kakounePlugins.kak-fzf ];
    config = {
      hooks = [
        {
          name = "BufOpenFile";
          option = ".*";
          commands = "editorconfig-load";
        }
        {
          name = "BufNewFile";
          option = ".*";
          commands = "editorconfig-load";
        }
      ];
    };
    extraConfig = ''
      eval %sh{kak-lsp --kakoune -s $kak_session}  # Not needed if you load it with plug.kak.
      lsp-enable
      map global normal <c-p> ':fzf-mode<ret>'
      map global normal '#' ':comment-line<ret>'
      add-highlighter global/ show-whitespaces
      add-highlighter global/ number-lines -hlcursor
      add-highlighter global/ regex \h+$ 0:Error

      try %{ source "%val{config}/unmanaged.kak" } catch %{}
    '';
  };

  programs.git = {
    enable = true;
    userName = "~ayum";
    userEmail = "ayum@users.noreply.github.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      br = "branch";
      st = "status";
    };
    difftastic = {
      enable = true;
      background = "dark";
    };
  };
}
