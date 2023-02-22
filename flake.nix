{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:jlesquembre/nixpkgs/nixpkgs-updater";
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
              default = pkgs.callPackage ./pkgs/default.nix {
                projectSrc = ./.;
              };

              # On nixpkgs we should have something like this on pkgs/top-level/all-packages.nix:
              # callPackage ../pkgs/path/to/my-package { };
              # In this example, that repository have a default.nix file (just a copy of `pkgs/default.nix` on this repo)
              # an a `info.json` file (generated with `passthru.updateScript`)

            };
        });
}
