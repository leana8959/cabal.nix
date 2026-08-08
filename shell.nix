let
  sources = import ./npins;
in

{
  # Build tools with GHC == 9.12
  # https://github.com/haskell/cabal/pull/11857
  pkgs ? import sources.nixpkgs { },

  withHLS ? true,
}:

let
  inherit (pkgs) lib;

  assertVersion =
    expectedVersion: drv:
    lib.throwIfNot (lib.getVersion drv == expectedVersion) ''
      Want ${lib.getName drv} ${expectedVersion}, but got ${lib.getVersion drv}.
    '' drv;
in

let
  pkgs_stackage_22_43 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/b6b38bb0649cb8393492949e01b1e331c3a05718.tar.gz";
    sha256 = "sha256-D408QVHL43RPYdPnGhTpBHJs4wVIebbsmh/SAAY0vAE=";
  }) { };

  pkgs_stackage_24_38 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/7fdb15681cb5daa386e25abe7ce611d2744ecc83.tar.gz";
    sha256 = "sha256-QGbXhs6gSMg8w+kNco0UY5RVX0V1GWy+B/HGGPfU3dY=";
  }) { };
in

let
  fourmolu =
    let
      inherit (pkgs_stackage_22_43.haskell.lib) dontCheck justStaticExecutables;
    in
    dontCheck (
      justStaticExecutables (pkgs_stackage_22_43.haskellPackages.callPackage ./fourmolu_0.12.0.0.nix { })
    );

  hlint =
    let
      inherit (pkgs_stackage_24_38.haskell.lib) justStaticExecutables;
    in
    justStaticExecutables (pkgs_stackage_24_38.haskellPackages.callPackage ./hlint_3.10.nix { });
in

pkgs.mkShell {
  name = "cabal";
  packages = [
    (assertVersion "3.10" hlint)
    (assertVersion "0.12.0.0" fourmolu)
    pkgs.haskell.compiler.ghc912

    pkgs.typos

    # TODO: add apply-refact of recommended version
    pkgs.haskellPackages.doctest
    pkgs.haskellPackages.fix-whitespace

    pkgs.cabal-install
    pkgs.pkg-config
    pkgs.zlib.dev
  ]
  ++ lib.optionals withHLS [
    pkgs.haskell.packages.ghc912.haskell-language-server
  ]
  ++ [
    pkgs.npins
  ];
}
