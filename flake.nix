{
  description = "A basic package";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.wamr-nix.url = "github:pineapplehunter/wamr-nix";
  inputs.wamr-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      wamr-nix,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      eachSystem =
        f:
        lib.genAttrs (import inputs.systems) (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
                wamr-nix.overlays.default
              ];
            }
          )
        );
    in
    {
      overlays.default =
        final: prev:
        lib.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = ./pkgs;
        };

      packages = eachSystem (pkgs: {
        default = pkgs.wasmbench;
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);

      legacyPackages = eachSystem lib.id;
    };
}
