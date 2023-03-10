{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:jlesquembre/nixpkgs/share-nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        {
          packages =
            {
              default = pkgs.callPackage "${nixpkgs}/pkgs/applications/misc/simple-pkg/default.nix" {
                # Use this as src, overriding the value on nixpkgs
                projectInfo = {
                  src = ./.;
                  version = "DEV";
                };
              };
            };
        });
}
