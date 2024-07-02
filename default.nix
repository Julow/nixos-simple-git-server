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
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    git_home = mkOption { type = types.path; };
    git_public_key = mkOption { type = types.str; };
    admin_public_key = mkOption { type = types.str; };

  };

  config = lib.mkIf conf.enable {
    users.groups.git.members = [ "git" "git-admin" ];

    users.users.git = {
      isNormalUser = true;
      group = "users";
      home = conf.git_home;
      openssh.authorizedKeys.keys = [ conf.git_public_key ];
      packages = [ pkgs.git ];
      shell = "${pkgs.git}/bin/git-shell";
    };

    users.users.git-admin = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ conf.admin_public_key ];
      packages = [ pkgs.git git_admin_tools ];
    };

  };
}
