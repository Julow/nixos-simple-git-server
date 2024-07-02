# Nixos Simple Git Server

Setup a private Git server and simple administration tools.

## Usage

Repositories are accessible under the `git` user:

```sh
git clone git@my_host:repo_name
```

### Administrating repositories

Creating a repository:

```sh
ssh git-admin@my_host create_repo repo_name
```

## Installation

Configuration:

```nix
{ ... }:

let

  pub_key = "...";

in {
  # Git server
  services.simple-git-server = {
    enable = true;
    git_home = "/var/data/git";
    git_public_key = pub_key;
    admin_public_key = pub_key;
  };
}
```

`flake.nix`:

```nix
{
  inputs = {
    # ...
    simple-git-server = {
      url = "github:Julow/nixos-simple-git-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      mk_nixos = path:
        import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" {
          system = "x86_64-linux";
          # Make sure to pass inputs as special args to make nix-gc-env
          # available to the configuration:
          specialArgs = inputs;
          modules = [ path ];
        };

    in {
      nixosConfigurations.default = mk_nixos ./configuration.nix;
    };
}
```
