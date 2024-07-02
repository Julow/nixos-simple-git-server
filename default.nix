{ config, pkgs, lib, ... }:

# Git server
#
# The "git" user has fetch and push access to the repositories
# The "git-admin" user can create and list repositories

let
  conf = config.services.simple-git-server;

  git_admin_tools =
    pkgs.callPackage ./git_admin_tools.nix { inherit (conf) git_home; };

in {
  options.services.simple-git-server = with lib; {
    enable = mkEnableOption "services.simple-git-server";

    git_home = mkOption {
      type = types.path;
      default = "/home/git";
      example = ''"/data/git"'';
      description = ''
        Path to the directory containing the Git repositories.
      '';
    };

    git_public_key = mkOption {
      type = types.listOf types.str;
      description = ''
        Authorized keys for accessing the Git repositories.
      '';
    };

    admin_public_key = mkOption {
      type = types.listOf types.str;
      description = ''
        Authorized keys for administrating the Git repositories.
      '';
    };

  };

  config = lib.mkIf conf.enable {
    users.groups.git.members = [ "git" "git-admin" ];

    users.users.git = {
      isNormalUser = true;
      home = conf.git_home;
      createHome = false; # 'createHome' resets the permissions on reboot
      group = "git";
      openssh.authorizedKeys.keys = conf.git_public_key;
      packages = [ pkgs.git ];
      shell = "${pkgs.git}/bin/git-shell";
    };

    users.users.git-admin = {
      isNormalUser = true;
      group = "git";
      openssh.authorizedKeys.keys = conf.admin_public_key;
      packages = [ pkgs.git git_admin_tools ];
    };

    system.activationScripts.git.text = ''
      data=${lib.escapeShellArg conf.git_home}
      mkdir -p "$data"
      chown git:git "$data"
      chmod 770 "$data"
      chmod g+s "$data"
      ${pkgs.acl}/bin/setfacl -m "default:group::rwx" "$data"
    '';
  };
}
