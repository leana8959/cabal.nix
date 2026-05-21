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
  inherit (pkgs) lib;
  inherit (pkgs) haskellPackages;
  inherit (pkgs.haskell.lib) justStaticExecutables;
in

let
  toUnderscoreVersion = version: "ghc-${lib.replaceString "." "_" version}";
in

pkgs.mkShell {
  name = "cabal";
  packages = [
    ghcs-nix.${toUnderscoreVersion ghcVersion}

    (justStaticExecutables (haskellPackages.callCabal2nix "hlint" sources.hlint { }))
    # apply-refact doesn't build
    haskellPackages.doctest
    haskellPackages.fix-whitespace

    pkgs.cabal-install
    pkgs.pkg-config
    pkgs.zlib.dev
  ];
}
