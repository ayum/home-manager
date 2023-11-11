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
    ]);

    home.file.".profile_ssh_logout".text = mkIf (cfg.ssh.enable && cfg.ssh.logoutHooks != []) (concatStringsSep "\n" (cfg.ssh.logoutHooks));

    home.file.".profile_ssh".text = mkIf (cfg.ssh.enable && cfg.ssh.loginHooks != []) (concatStringsSep "\n" (cfg.ssh.loginHooks));
  };
}
