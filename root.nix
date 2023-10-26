{ pkgs, home-manager, config, ... }:

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
    pkgs.nodePackages_latest.bash-language-server
    pkgs.cmake-language-server
    pkgs.nodePackages_latest.vscode-json-languageserver
    pkgs.rnix-lsp
    pkgs.yaml-language-server
    pkgs.zls
    pkgs.python311Packages.python-lsp-server
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
    pkgs.python313
    pkgs.scons
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

  xdg = {
    enable = true;
  };

  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      use-xdg-base-directories = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.file."${config.xdg.configHome}/clangd/config.yaml".text = ''
    CompileFlags:
      Add: [--include-directory=/usr/include]
  '';

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "tmux" "python" ];
      theme = "robbyrussell";
    };
    initExtra = ''
      unsetopt share_history
      setopt inc_append_history
    '';
    shellAliases = {
    };
    sessionVariables = {
      ZSH_TMUX_AUTOSTART = true;
      ZSH_TMUX_UNICODE = true;
      ZSH_TMUX_CONFIG = "${config.xdg.configHome}/tmux/tmux.conf";
    };
  };

  programs.tmux = {
    enable = true;
    historyLimit = 12345678;
    terminal = "tmux-256color";
    escapeTime = 25;
    clock24 = true;
    aggressiveResize = true;
    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      bind S-Up move-pane -h -t '.{up-of}'
      bind S-Right move-pane -t '.{right-of}'
      bind S-Left move-pane -t '.{left-of}'
      bind S-down move-pane -h -t '.{down-of}'
    '';
  };


  home.file."${config.xdg.configHome}/kak/plugins/kakoune-registers".source =
    let
      kakoune-registers = pkgs.fetchFromGitHub {
        owner = "Delapouite";
        repo = "kakoune-registers";
        rev = "b8ca8e04ebe50671a937bceccba69c62b68ae8b0";
        sha256 = "k9EGgf9VEbDATmI0s0owwzfZ5aoWbjAZw714Kg1rxW8=";
      };
    in "${kakoune-registers}";
  home.file."${config.xdg.configHome}/kak/plugins/byline.kak".source =
    let
      byline.kak = pkgs.fetchFromGitHub {
        owner = "evanrelf";
        repo = "byline.kak";
        rev = "a27d109b776c60e11752eeb3207c989a5e157fc0";
        sha256 = "Aa0UnioD20HfGiTtC7Tmbs+xYgaytz3pUsXQWkzrLYg=";
      };
    in "${byline.kak}";
  home.file."${config.xdg.configHome}/kak/colors".source =
    let
      kakoune-themes = pkgs.fetchFromGitHub {
        owner = "anhsirk0";
        repo = "kakoune-themes";
        rev = "910a3fd7196f360c66e8cf5608870a98483f2a6d";
        hash = "sha256-mqVMdfgZW22qGfWuVNru/yRdKIlbWk/iG6iuQI2T+4M=";
      };
    in "${kakoune-themes}/colors";
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
        {
          name = "ModuleLoaded";
          option = "tmux";
          commands = "alias global terminal tmux-terminal-vertical";
        }
        {
          name = "RegisterModified";
          option = "/";
          commands = ''add-highlighter -override global/search regex "%reg{/}" 0:CurSearch'';
        }
      ];
      keyMappings = [
        {
          key = "l";
          mode = "user";
          docstring = "lsp mode";
          effect = ":enter-user-mode lsp<ret>";
        }
        {
          key = "p";
          mode = "user";
          docstring = "fzf mode";
          effect = ":fzf-mode<ret>";
        }
        {
          key = "r";
          mode = "user";
          docstring = "registers view";
          effect = ":info-registers<ret>";
        }
        {
          key = "/";
          mode = "normal";
          effect = "/(?i)";
        }
        {
          key = "<a-/>";
          mode = "normal";
          effect = "<a-/>(?i)";
        }
      ];
      colorScheme = "mygruvbox";
    };
    extraConfig = ''
      eval %sh{kak-lsp --kakoune -s $kak_session}  # Not needed if you load it with plug.kak.
      lsp-enable
      map global normal '#' ':comment-line<ret>'
      add-highlighter global/ show-whitespaces
      add-highlighter global/ show-matching
      add-highlighter global/ number-lines -hlcursor
      add-highlighter global/ regex \h+$ 0:Error
      set-face global CurSearch +u

      source "%val{config}/plugins/kakoune-registers/registers.kak"
      source "%val{config}/plugins/byline.kak/rc/byline.kak"
      require-module "byline"

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
      rp = "rev-parse";
    };
    difftastic = {
      enable = true;
      background = "dark";
    };
  };
}
