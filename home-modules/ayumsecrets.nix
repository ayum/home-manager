{ pkgs, lib ? pkgs.lib, home-manager, config, ... }:

with lib;

let
  cfg = config.ayum.secrets;
  secretsDir = "${config.xdg.dataHome}/ayum/secrets";
  secretModule = types.submodule ({ config, ... }: {
    options = {
      path = mkOption {
        type = types.str;
        default = "";
        example = ''
          ''${config.xdg.configHome/someapp/plaintext.conf}
        '';
        description = "Path (with filename component) to where secret will be decrypted.";
      };
      ciphertext = mkOption {
        type = types.str;
        default = "";
        description = ''
          Text from `gpg --encrypt --armor plaintext.file`. Should start with -----BEGIN PGP MESSAGE-----.
        '';
      };
      mode = mkOption {
        type = types.str;
        default = "";
        description = ''
          If not empty chmod command with the mode is issued upon plaintext file in form `chmod ''$mode plaintext.file`. May be symbolic or numeric as well.
        '';
      };
    };
  });
  secretsTargetDir = if cfg.enablePlaintextOnRest then "${config.home.homeDirectory}" else "/run/user/$userid/ayum/secrets";
  secretsScript = (pkgs.writeShellScriptBin "ayum-secrets.sh" ''
set -e
userid=$(${pkgs.coreutils}/bin/id -ru)
ayumsecretstargetdir="${secretsTargetDir}"
secretsdir=${secretsDir}
cleanup () { :; }
trap '[ $? -eq 0 ] && { cleanup; exit 0; } || { cleanup; echo "Decryption failed for all or some secrets.${(optionalString (cfg.enableExitOnFail) "Disconnecting")}"; exit 1; }' EXIT
${(optionalString (! cfg.enablePlaintextOnRest) ''
${pkgs.gnupg}/bin/gpgconf --kill gpg-agent 1>&2 2>/dev/null || :
${pkgs.gnupg}/bin/gpgconf --remove-socketdir 1>&2 2>/dev/null || :
${pkgs.coreutils}/bin/rm -rf /run/user/$userid/gnupg
${pkgs.coreutils}/bin/touch /run/user/$userid/gnupg
echo -e "%Assuan%\nsocket=${config.home.homeDirectory}/.gnupg/S.gpg-agent" > /run/user/$userid/gnupg/S.gpg-agent 
echo -e "%Assuan%\nsocket=${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh" > /run/user/$userid/gnupg/S.gpg-agent.ssh 
${pkgs.coreutils}/bin/chmod +t /run/user/$userid/gnupg
${pkgs.gnupg}/bin/gpg-connect-agent --no-autostart -S "${config.home.homeDirectory}/.gnupg/S.gpg-agent" "GETINFO pid" /bye 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q -i "ERR 67109115 " || { echo "It seems that forwarded gpg-agent in not running, not decrypting anything"; false; }
cd ${config.home.homeDirectory}
${pkgs.coreutils}/bin/mkdir -p $ayumsecretstargetdir
${pkgs.coreutils}/bin/chmod +t $ayumsecretstargetdir
'')}
test -d "$secretsdir" || { echo "No secrets to decrypt, nonexistent root secrets directory"; exit 0; }
ayumdecrypt () {
  local fin="$secretsdir/$1"
  local fname="''${1%.*}"
  local f="$ayumsecretstargetdir/$fname"
  if test ! -e "$f" || test $(${pkgs.coreutils}/bin/stat -c %Y "$f") -eq 1; then
    local mode="$(stat -L --format '%a' "$f" 2>/dev/null)"
    ${pkgs.coreutils}/bin/install -b -D /dev/null "$f"
    ${pkgs.coreutils}/bin/rm -f "$f"
    printf "%s " "Decrypting ${config.home.homeDirectory}/$fname"
    ${pkgs.gnupg}/bin/gpg --no-autostart --decrypt --output "$f" "$fin" 1>&2 2>/dev/null && echo "ok" || false
    if [ -n "$mode" ]; then ${pkgs.coreutils}/bin/chmod "$mode" "$f"; fi
    mode=$(${pkgs.gnused}/bin/sed -n 's/^Comment: mode=//gp' "$fin" | head -n1)
    if [ -n "$mode" ]; then ${pkgs.coreutils}/bin/chmod "$mode" "$f"; fi 
    ${pkgs.coreutils}/bin/chmod +t "$f"
  fi
}
for fin in $(cd "$secretsdir"; find ./ -name '*.gpg' -or -name '*.asc'); do
  f="''${fin%.*}"
  ayumdecrypt "$fin"
  ${(optionalString (cfg.enablePlaintextOnRest) "continue")}
  test -e "$f" || ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$f")"
  if test -L "$f"; then
    path="$(${pkgs.coreutils}/bin/realpath -m "$f")"
    storepath="$(${pkgs.coreutils}/bin/realpath -m "$ayumsecretstargetdir/$f")"
    test "$path" = "$storepath" || ${pkgs.coreutils}/bin/unlink "$f"
  fi
  test -e "$f" || ${pkgs.coreutils}/bin/ln -s "$ayumsecretstargetdir/$f" "$f"
  if test ! -L "$f"; then
    test -e "$f" && { ${pkgs.coreutils}/bin/mv -f "$f" "$f.backup"; ${pkgs.coreutils}/bin/ln -s "$ayumsecretstargetdir/$f" "$f"; }
  fi
done
cleanup
  '');
in
{
  options = {
    ayum.secrets = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable secrets decryption on login with gpg.
        '';
      };
      enablePlaintextOnRest = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Wether decryption will be in persistent filesystem or tmpfs.
        '';
      };
      enableSsh = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Wether to decrypt on ssh login or regular user profile only.
        '';
      };
      enableExitOnFail = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to exit login session if decryption failed.
        '';
      };
      secrets = mkOption {
        type = types.listOf secretModule;
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {
    ayum.profile = {
      enable = true;
      loginHooks = [''
          ${pkgs.dash}/bin/dash ${secretsScript}/bin/ayum-secrets.sh ${(optionalString (cfg.enableExitOnFail) "|| exit 1")}
      ''];
      ssh = mkIf (cfg.enableSsh) {
        enable = true;
        loginHooks = [''
          ${pkgs.dash}/bin/dash ${secretsScript}/bin/ayum-secrets.sh ${(optionalString (cfg.enableExitOnFail) "|| exit 1")}
        ''];
        logoutHooks = [''
          userid=$(${pkgs.coreutils}/bin/id -ru)
          ${pkgs.socat}/bin/socat -u OPEN:/dev/null UNIX-CONNECT:${config.home.homeDirectory}/.gnupg/S.gpg-agent 2>/dev/null || ${pkgs.coreutils}/bin/rm -f "${config.home.homeDirectory}/.gnupg/S.gpg-agent"
          ${pkgs.socat}/bin/socat -u OPEN:/dev/null UNIX-CONNECT:${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh 2>/dev/null || ${pkgs.coreutils}/bin/rm -f "${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh"
          test -f /run/user/$userid/gnupg && ${pkgs.coreutils}/bin/rm -f /run/user/$userid/gnupg;
        ''];
      };
    };
    home.file = let
      stripHomedir = path: lib.strings.removePrefix ("${config.home.homeDirectory}/") (lib.strings.normalizePath path);
    in mkMerge (map (secret: let
        secretPath = stripHomedir secret.path;
      in {
        "${secretsDir}/${secretPath}.asc" = {
          text = let
            asc = builtins.split "\n ?\n" "${secret.ciphertext}";
          in
            ''
              ${builtins.head asc}${optionalString (secret.mode != "") "\nComment: mode=${secret.mode}"}

              ${builtins.head (builtins.tail (builtins.tail asc))}
          '';
          onChange = ''
            userid=$(${pkgs.coreutils}/bin/id -ru)
            test -f "${secretsTargetDir}/${secretPath}" && (${pkgs.coreutils}/bin/touch -m --date=@1 "${secretsTargetDir}/${secretPath}"; ${(optionalString (secret.mode != "") "chmod ${secret.mode} \"${secretsTargetDir}/${secretPath}\";")} )
          '';
        };
      }
    ) cfg.secrets);
  };
}
