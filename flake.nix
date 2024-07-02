{
  description = "Simple Git server.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, ... }: { nixosModules.default = import ./default.nix; };
}
