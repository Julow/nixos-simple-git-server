{ stdenv, pkgs, git_home }:

let
  git = "${pkgs.git}/bin/git";

  create_repo = pkgs.writeScriptBin "create_repo" ''
    set -e
    die () { echo "$1"; exit 1; }
    if [[ $# -lt 1 ]]; then die "Missing argument: Repository name"; fi
    if [[ -z $1 ]] || [[ $1 = */* ]]; then die "$1: Invalid name"; fi
    ABS_NAME="${git_home}/$1"
    if [[ -e $ABS_NAME ]]; then die "$1: Already exists"; fi
    ${git} init --bare "$ABS_NAME"
  '';

  list_repos = pkgs.writeScriptBin "list_repos" ''
    ls -1 "${git_home}"
  '';

in pkgs.symlinkJoin {
  name = "git-admin-tools";
  paths = [ create_repo list_repos ];
}
