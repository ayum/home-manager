{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

with lib;

let
  cfg = config.ayum.profile;
  sshLogoutScript = "${config.home.homeDirectory}/.profile_ssh_logout";
  logoutScript = "${config.home.homeDirectory}/.profile_logout";
in
{
  options = {
    ayum.profile = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to create .profile in home dir.
        '';
      };
      extraLinesPrepend = mkOption {
        type = types.lines;
        default = "";
        example = "unset SSH_AUTH_SOCK";
        description = ''
          Extra line in .profile before sourceing sessions variables.
        '';
      };
      extraLines = mkOption {
        type = types.lines;
        default = "";
        example = "source ~/.bashrc";
        description = ''
          Extra line in .profile.
        '';
      };
      userBin = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Wether to extend PATH for user private bin dir.
          '';
        };
      };
      bash = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Wether to include bash integration (.bashrc sourceing) into .profile.
          '';
        };
      };
      ssh = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to include ssh related detections in .profile.
          '';
        };
        loginHooks = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Hooks to execute on ssh shell startup (only login shells).
          '';
        };
        logoutHooks = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Hook to execute on ssh shell teardown (only login shells).
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.file.".profile".text = concatStringsSep "\n" ([
''
${cfg.extraLinesPrepend}
''

''
. "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"

trap -- 'test -f "${logoutScript}" && . "${logoutScript}"' EXIT
''

(optionalString cfg.ssh.enable
''
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SESSION_TYPE=remote/ssh
else
  case $(${pkgs.ps}/bin/ps -o comm= -p "$PPID") in
    sshd|*/sshd) SESSION_TYPE=remote/ssh;;
  esac
fi
if [ $SESSION_TYPE = "remote/ssh" ]; then
  ssh_logout_script="${config.home.homeDirectory}/.profile_ssh_logout"
  trap -- 'test -f "${sshLogoutScript}" && . "${sshLogoutScript}"; test -f "${logoutScript}" && . "${logoutScript}"' EXIT
  test -f "${config.home.homeDirectory}/.profile_ssh" && . "${config.home.homeDirectory}/.profile_ssh"
fi
'')

(optionalString (cfg.bash.enable)
''
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
'')

(optionalString (cfg.userBin.enable)
''
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
'')

''
${cfg.extraLines}
''
    ]);

    home.file = {
      ".profile_ssh_logout" = mkIf (cfg.ssh.enable && cfg.ssh.logoutHooks != []) {
        text = (concatStringsSep "\n" (cfg.ssh.logoutHooks));
      };
      ".profile_ssh" = mkIf (cfg.ssh.enable && cfg.ssh.loginHooks != []) {
        text = (concatStringsSep "\n" (cfg.ssh.loginHooks));
      };
    };
  };
}
