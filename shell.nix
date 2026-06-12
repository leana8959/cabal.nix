let
  sources = import ./npins;
in

{
  # Build tools with GHC == 9.12
  # https://github.com/haskell/cabal/pull/11857
  pkgs ? import sources.nixpkgs { },

  ghcVersion ? "9.12.3",
}:

let
  ghcs-nix = import sources.ghcs-nix;
  pkgs_stackage_22_43 = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b6b38bb0649cb8393492949e01b1e331c3a05718";
    hash = "sha256-D408QVHL43RPYdPnGhTpBHJs4wVIebbsmh/SAAY0vAE=";
  }) { };

  pkgs_stackage_24_38 = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "7fdb15681cb5daa386e25abe7ce611d2744ecc83";
    hash = "sha256-QGbXhs6gSMg8w+kNco0UY5RVX0V1GWy+B/HGGPfU3dY=";
  }) { };
in

let
  inherit (pkgs) lib;
in

let
  toUnderscoreVersion = version: "ghc-${lib.replaceString "." "_" version}";
in

let
  fourmolu-0_12_0_0 =
    let
      inherit (pkgs_stackage_22_43.haskell.lib) dontCheck justStaticExecutables;
    in
    dontCheck (
      justStaticExecutables (pkgs_stackage_22_43.haskellPackages.callHackage "fourmolu" "0.12.0.0" { })
    );

  hlint-3_10 =
    let
      inherit (pkgs_stackage_24_38.haskell.lib) justStaticExecutables;
    in
    justStaticExecutables (pkgs_stackage_24_38.haskellPackages.callHackage "hlint" "3.10" { });
in

pkgs.mkShell {
  name = "cabal";
  packages = [
    ghcs-nix.${toUnderscoreVersion ghcVersion}

    hlint-3_10
    fourmolu-0_12_0_0

    pkgs.typos

    # apply-refact doesn't build
    pkgs.haskellPackages.doctest
    pkgs.haskellPackages.fix-whitespace

    pkgs.cabal-install
    pkgs.pkg-config
    pkgs.zlib.dev
  ];
}
