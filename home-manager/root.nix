{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

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
    package = lib.mkDefault pkgs.nix;
    settings = {
      use-xdg-base-directories = true;
      extra-nix-path = "nixpkgs=flake:nixpkgs";
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
      extraConfig = ''
        DISABLE_AUTO_UPDATE=true
      '';
    };
    initExtra = ''
      unsetopt share_history
      setopt inc_append_history

      function ka () {
        kak -clear;
        session=$(kak -l | head -1);
        if test -z $session; then
          kak -s default "$@"
        else
          kak -c $session "$@"
        fi
      }
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
      set -g allow-passthrough on
    '';
  };

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
    plugins = [
      pkgs.kakounePlugins.kak-fzf
      pkgs.kakounePlugins.kak-byline
      pkgs.kakounePlugins.kakoune-registers
    ];
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
          key = "<a-i>";
          mode = "prompt";
          effect = "(?i)";
        }
      ];
      colorScheme = "mygruvbox";
    };
    extraConfig = ''
      eval %sh{kak-lsp --kakoune -s $kak_session}
      lsp-enable

      map global normal '#' ':comment-line<ret>'
      add-highlighter global/ show-whitespaces
      add-highlighter global/ show-matching
      add-highlighter global/ number-lines -hlcursor
      add-highlighter global/ regex \h+$ 0:Error
      set-face global CurSearch +u

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

  services.gpg-agent.enable = false;
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        text = ''
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
OasH
=2pHM
-----END PGP PUBLIC KEY BLOCK-----
        '';
      }
    ];
  };
}
