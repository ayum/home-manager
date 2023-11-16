{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
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
    profileExtra = ''
      emulate sh -c '. ~/.profile'
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
      pkgs.kakounePlugins.smarttab-kak
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
        {
          name = "BufWritePre";
          option = ".*";
          commands = ''try %{ execute-keys -draft \%s\h+$<ret>d }'';
        }
        {
          name = "FocusOut";
          option = ".*";
          commands = "try %{ write }";
        }
        {
          name = "ModeChange";
          option = ".*:insert:.*";
          commands = "try %{ write }";
        }
        {
          name = "NormalIdle";
          option = ".*";
          commands = "try %{ write }";
        }
        {
          name = "BufCreate";
          option = ".*";
          commands = ''
            editorconfig-load
            autoconfigtab
          '';
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
        {
          key = ".";
          mode = "user";
          docstring = "resource kakrc";
          effect = '':source "%val{config}/kakrc"<ret>'';
        }
      ];
      colorScheme = "mygruvbox";
    };
    extraConfig = ''

      declare-option -hidden bool init_done

      map global normal '#' ':comment-line<ret>'
      add-highlighter -override global/ show-whitespaces
      add-highlighter -override global/ show-matching
      add-highlighter -override global/ number-lines -hlcursor
      add-highlighter -override global/ regex \h+$ 0:Error
      set-face global CurSearch +u

      require-module "byline"

      eval %sh{
        $kak_opt_init_done && exit
        kak-lsp --kakoune -s $kak_session
      }
      try %{ lsp-enable }

      try %{ source "%val{config}/unmanaged.kak" } catch %{}

      set-option global init_done true
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

  services.ssh-agent.enable = lib.mkDefault false;
  services.gpg-agent = {
    enable = lib.mkDefault false;
    pinentryFlavor = lib.mkDefault "curses";
  };
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        text = ''
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEZVPoIhYJKwYBBAHaRw8BAQdAbbsFLhaMndEOi9sviAHNKgoZnOeH+1bly7gL
RZsSQhq0FH5heXVtIDxheXVtQGF5dW0ucnU+iI4EExYKADYWIQQPjYFdkQASNH3D
Hil25B9vonLm1gUCZVPoIgIbAQQLCQgHBBUKCQgFFgIDAQACHgUCF4AACgkQduQf
b6Jy5tZJOQEAgMXr8R5rCvpfIZZslUuVfhX5xfn0hvRzWX5vKVMhr9YA/iBOOdBm
aDyOxDYmAin+eItJFJSJD8OyE9atdSrrg5ILuDMEZVPzGhYJKwYBBAHaRw8BAQdA
x5eOzoAQetzXlf91f62RIaIIiSQux8EldX6NDo3qYUmI7gQYFgoAIBYhBA+NgV2R
ABI0fcMeKXbkH2+icubWBQJlU/gWAhsCAIAJEHbkH2+icubWdSAEGRYKAB0WIQTq
As+Wb0b7itBYmHb1AY7SGc/GFQUCZVP4FgAKCRD1AY7SGc/GFcIsAQCwP1rghTW2
qVNLYp1s6bvjSe4HmpsW/YJmCjFqvjkciAD0CRbCSh3QjgUjBN6x6c63vB3a0SfI
6ft6bbmr8YwqBglIAPwMFdE4Oafz9LkMjm3FE8/ecHaCLTEdmQ6doXXchEIQMAD7
BM+FkOCaXmGXEKW7TfAoPM79ObDOK0Du3FO5DULhGwC4OARlU/MaEgorBgEEAZdV
AQUBAQdAAMj97mNcWRdljZubjlk6Q/SrjpTObOA1ZMB1AHRtTH8DAQgHiHgEGBYK
ACAWIQQPjYFdkQASNH3DHil25B9vonLm1gUCZVP4OgIbDAAKCRB25B9vonLm1gq5
AQCE4limB0nz07vqnrEYGhka6oQepd53HS3Fc0aC1s3NrAD/Zgeyj4nPGZavsd14
PmN02uIASQXtqe+sQLo1kT839AO4MwRlU/MaFgkrBgEEAdpHDwEBB0BwWIkTKdJH
PCxDgIWhJCO18BkYanVEtq2nRg+ozYWRU4jvBBgWCgAgFiEED42BXZEAEjR9wx4p
duQfb6Jy5tYFAmVT+FUCGyIAgQkQduQfb6Jy5tZ2IAQZFgoAHRYhBHfvm0Dqg+LW
PZF5tWFL+FV5yVwHBQJlU/hVAAoJEGFL+FV5yVwHOCEA/20kBFjyLRl5s4ZP8ad7
/drT4bgwb/jM8kfOMF3PGxvDAQC7k4u21CwDnx+kUh0Y+YkZzr0n7sZbHTpcUwlb
/cd9DVI9AQDfAo3DANuTjIbQWSOxe7M4SFJ4d34wU+Q3DCzPyHLyIQD8Dbdv+ucZ
XEV9vzIFi05wwKQ+uT/CTGgqWIeqPAJr8Ac=
=o100
-----END PGP PUBLIC KEY BLOCK-----
        '';
      }
    ];
  };
}
