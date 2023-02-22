# Nixpkgs Updater example

This is an example for https://github.com/NixOS/nixpkgs/issues/217679

The goal is automatically keep in sync open source projects providing a nix
derivation (like this project) with nixpkgs.

To do that, we can use 2 new helper functions( `nixpkgsUpdater` and
`srcFromJSON`) and follow some convetions:

1. Define a package (in this example, in the `flake.nix`) like this:

   ```nix
   packages.default = pkgs.callPackage ./pkgs/default.nix {
     projectSrc = ./.;
   };
   ```

   Notice that we have to move the derivation to its own file, and in our flake
   we must provide one argument, `projectSrc`, the path to our project.

1. Write a derivation almost like we do for any other nixpkgs derivation, with
   some extra parts:

   ```nix
   {
     # New helper functions
     nixpkgsUpdater
   , srcFromJSON

     # - Path to an "info.json" file (That's the case in nixpkgs, generated with nixpkgsUpdater)
     # - The src attribute passed to mkDerivation (That's the case in our repository)
   , projectSrc ? ./info.json
   }:

   let
     # Here we get `src` and `version` for stdenv.mkDerivation
     # In our repo, this function doesn't do much, just passed the projectSrc
     # value, but on nixpkgs, gets the source based on the date in `info.json`
     srcData = srcFromJSON projectSrc;
   in

   stdenv.mkDerivation {
     pname = "simple";
     inherit (srcData) src version;

     # Function to be executed by r-ryantm bot
     passthru.updateScript = nixpkgsUpdater {
       fetcher = "fetchFromGitHub";
       fetcherArgs = {
         owner = "github-username";
         repo = "simple-flake";
       };
       # List of files to sync with nixpkgs, relative to the Git repository root.
       syncFiles = [ "pkgs/default.nix" ];
     };
   }
   ```

   For a full example see `pkgs/default.nix`

1. Finally, to add our package to nixpkgs, we have to add an entry to
   `pkgs/top-level/all-packages.nix`. To generate the `info.json` file can do:
   `nix build /path/to/local/nixpkgs#simple-pkg.updateScript; ./result`
