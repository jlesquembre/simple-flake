# Share code example

This is an example for https://github.com/NixOS/nixpkgs/issues/217679

The goal is to reduce duplication between Nixpkgs and Nix files in upstream
projects (like this project).

To do that, the idea is to commit the shared nix expressions to Nixpkgs.
Following some convetions, we can reuse the nix expressions in the upstream
project.

For a full derivation example, see
https://github.com/jlesquembre/nixpkgs/blob/share-nixpkgs/pkgs/applications/misc/simple-pkg/default.nix

1. (**upstream**) Define a package (in this example, in the `flake.nix`) like
   this:

   ```nix
   packages.default = pkgs.callPackage "${nixpkgs}/pkgs/applications/misc/simple-pkg/default.nix" {
     # Use this as src, overriding the value on nixpkgs
     projectInfo = {
       src = ./.;
       version = "DEV";
     };
   };
   ```

1. (**Nixpkgs**) Our expression is defined like this:

   ```nix
   {
     # ...
     nixpkgsUpdater # Optional
   , srcFromJSON

     # projectInfo is overloaded, it can be:
     # - Path to an "info.json" file (That's the case in nixpkgs)
     # - Attribute set with values to use in mkDerivation
   , projectInfo ? srcFromJSON ./info.json
   }:

   stdenv.mkDerivation {
     pname = "simple";
     inherit (srcData) src version;

     # Function to be executed by r-ryantm bot
     # nixpkgsUpdater is optional
     passthru.updateScript = nixpkgsUpdater {
       fetcher = "fetchFromGitHub";
       fetcherArgs = {
         owner = "github-username";
         repo = "simple-flake";
       };
     };
   }
   ```

1. (**Nixpkgs**) Notice that we have a `info.json` file in the same directory
   that the `default.nix` file:

   ```json
   {
     "fetcher": "fetchFromGitHub",
     "fetcherArgs": {
       "hash": "sha256-x9BrU5hj6HsnRudt7a7qEJOTX2WU1UdAxiPK40NLvew=",
       "owner": "jlesquembre",
       "repo": "simple-flake",
       "rev": "v1.0"
     },
     "version": "1.0"
   }
   ```

   `info.json` has to provide 2 fields, `fetcher` and `fetcherArgs`. `fetcher`
   is one of the fetchers defined in
   [Nixpkgs manual: Fetcher](https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-fetchers).
   `fetcherArgs` are the arguments to that function.

   We can create `info.json` manually or with the `nixpkgsUpdater` helper
   function:
   `nix build /path/to/local/nixpkgs#simple-pkg.updateScript; ./result`

## Update shared nix code

In our repository, nixpkgs is an input:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
};
```

To do changes, we can point nixpkgs to our local copy:

```nix
inputs = {
  nixpkgs.url = "/path/to/my/local/nixpkgs";
};
```
