{ pkgs, oldpkgs, lib ? pkgs.lib, home-manager, config, ... }:

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
    pkgs.yaml-language-server
    pkgs.zls
    pkgs.python311Packages.python-lsp-server
    pkgs.clang-tools
    pkgs.clang
    pkgs.nodePackages_latest.nodejs
    pkgs.editorconfig-core-c
    pkgs.mc
    pkgs.tig
    pkgs.git-filter-repo
    pkgs.git-subrepo
    pkgs.curl
    pkgs.wget
    pkgs.htop
    pkgs.iotop
    pkgs.zip
    pkgs.unzip
    pkgs.silver-searcher
    pkgs.fzf
    pkgs.python313
    pkgs.just
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
    package = lib.mkDefault pkgs.nixVersions.latest;
    settings = {
      use-xdg-base-directories = true;
      extra-nix-path = "nixpkgs=flake:nixpkgs";
      substituters = "https://cache.nixos.org https://ayum.cachix.org";
      trusted-public-keys = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ayum.cachix.org-1:LuR7eVuXPJK7PwgbmnvNQOp2FQ9TLTToyOVON8fpk3E=";
      experimental-features = ["ca-derivations" "nix-command" "flakes"];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.file."${config.xdg.configHome}/clangd/config.yaml".text = ''
    CompileFlags:
      Add: [--include-directory=/usr/include]
  '';

  programs.bash.enable = true;
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

  programs.git = {
    enable = true;
    aliases = {
      c   = "commit";
      cg  = ''!f() { : git commit; lastarg="''${@:$#:1}"; [[ ''$# == 0 ]] && lastarg=""; message="''${lastarg}"; [[ "''$lastarg" == -* ]] && message=""; [[ "''$lastarg" != -* ]] && lastarg=""; [[ ''$# -le 1 ]] && set -- ""; git commit "''${@:1:''$#-1}" ''$lastarg --message "''${message:-Fix from $(git rev-parse --quiet --verify --abbrev-ref HEAD)}"; }; f'';
      ce  = "commit --allow-empty";
      ceg = ''!f() { : git commit; git cg --allow-empty "''$@"; }; f'';
      cm  = "commit --amend";
      cf  = ''!f() { : git commit; git commit --fixup ''${1-HEAD} "''${@: 2}"; }; f'';
      a   = "add";
      aa  = "add --all";
      ac  = ''!f() { : git commit; git add --all && git commit "''$@"; }; f'';
      acm = ''!f() { : git commit; git add --all && git commit --amend "''$@"; }; f'';
      acg = ''!f() { : git commit; git add --all && git cg "''$@"; }; f'';
      acf = ''!f() { : git commit; lastarg="''${@:$#:1}"; [[ ''$# == 0 ]] && lastarg=""; commitish="''${lastarg}"; [[ "''$lastarg" == -* ]] && commitish=""; [[ "''$lastarg" != -* ]] && lastarg=""; [[ ''$# -le 1 ]] && set -- ""; git add --all && git commit "''${@:1:''$#-1}" ''$lastarg --fixup "''${commitish:-HEAD}"; }; f'';
      p   = "push";
      pf  = "push --force";
      f   = "fetch";
      fa  = "fetch --all";
      fe  = ''!f() { : git reset; upstream="''$(git rev-parse --quiet --verify --abbrev-ref --symbolic-full-name HEAD@{u})"; lastarg="''${@:$#:1}"; [[ ''$# == 0 ]] && lastarg=""; commitish="''${lastarg}"; [[ "''$lastarg" == -* ]] && commitish=""; [[ "''$lastarg" != -* ]] && lastarg=""; [[ ''$# -le 1 ]] && set -- ""; commitish="''${commitish:-$upstream}"; [[ "''$commitish" == */* ]] && remote="''${commitish%%/*}"; [[ "''$commitish" != */* ]] && remote="--all"; git fetch "''${remote}" && git reset "''${@:1:''$#-1}" ''$lastarg "''$commitish"; }; f'';
      u   = "pull";
      ut  = "pull --autostash";
      utr = "pull --autostash --rebase";
      utm = "pull --autostash --merge";
      k   = "checkout";
      kb  = "checkout --branch";
      b   = "branch";
      bf  = "branch --force";
      ba  = "branch --all";
      bl  = "branch --list";
      bal = "branch --all --list";
      bla = "bal";
      brl = "branch --remotes --list";
      blr = "brl";
      bd  = "branch --delete";
      bm  = "branch --merged";
      bdm = ''!f() { : git branch; main="''$(git xmain)"; lastarg="''${@:$#:1}"; [[ ''$# == 0 ]] && lastarg=""; commitish="''${lastarg}"; [[ "''$lastarg" == -* ]] && commitish=""; [[ "''$lastarg" != -* ]] && lastarg=""; [[ ''$# -le 1 ]] && set -- ""; git branch --merged "''${commitish:-$main}" | sed "s/^[*[:space:]]*//g" | grep -v "''$main" | grep ".*-.*" | xargs -I% git branch "''${@:1:''$#-1}" ''$lastarg --delete "%"; }; f'';
      w   = "switch";
      bw  = "switch -c";
      l   = "log";
      s   = "status";
      n   = "clean";
      nf  = "clean --force";
      nn  = "clean --dry-run";
      nd  = "clean -d";
      ndn = "clean -d --dry-run";
      ndf = "clean -d --force";
      v   = "rev-parse";
      t   = "stash";
      o   = "remote";
      e   = "reset";
      es  = "reset --soft";
      eh  = "reset --hard";
      h   = "show";
      m   = "merge";
      r   = "rebase";
      rq  = ''!f() { : git rebase; subj="''$(git log -1 --format=%s)"; subj="''${subj##*[Ff][Ii][Xx][Uu][Pp]! }"; lastarg="''${@:$#:1}"; [[ ''$# == 0 ]] && lastarg=""; commitish="''${lastarg}"; [[ "''$lastarg" == -* ]] && commitish=""; [[ "''$lastarg" != -* ]] && lastarg=""; [[ ''$# -le 1 ]] && set -- ""; git rebase "''${@:1:''$#-1}" ''$lastarg --autosquash ''$(git log -1 --format=%H --grep="^''${subj}$")^; }; f'';
      xdang = ''!git fsck --lost-found --name-objects --no-reflogs | grep "dangling commit" | sed -e "s@dangling commit @@" | xargs git show -s --format="%ct %H %cd %s" | sort -r | sed -e "s@^\\w*\\s*@@" | less -F'';
      xmain = ''!mainbranch="''$(git rev-parse --abbrev-ref origin/HEAD)"; echo ''${mainbranch#*/}'';
    };
    difftastic = {
      enable = true;
      background = "dark";
    };
    includes = [
      { path = "user.inc"; }
    ];
    extraConfig = {
      push = { autoSetupRemote = "true"; };
      pull = { ff = "only"; };
      advice = { diverging = "false"; };
      init = { defaultBranch = "master"; };
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "gruvbox";
      editor = {
#        lsp.display-messages = true;
      };
      keys.normal = {
#        ret = ["move_line_down" "goto_first_nonwhitespace"];
      };
    };
  };

  programs.ssh = {
    enable = lib.mkDefault true;
    includes = [
      "config.d/*"
    ];
    matchBlocks = {
      "github.com github gh" = {
          hostname = "github.com";
          user = "git";
          identitiesOnly = false;
      };
    };
  };

  services.ssh-agent.enable = lib.mkDefault false;
  services.gpg-agent = {
    enable = lib.mkDefault false;
    pinentryPackage = lib.mkDefault pkgs.pinentry-tty;
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
