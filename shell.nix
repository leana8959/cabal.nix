let
  sources = import ./npins;

  # This is the latest verison used in cabal's CI
  ghcVersionDefault = "ghc966";
in
{
  pkgs ?
    if builtins.hasAttr ghcVersion sources then
      import sources.${ghcVersion} { }
    else
      throw "${ghcVersion} is not pinned, try pinning it or passing a nixpkgs instance instead",

  ghcVersion ? ghcVersionDefault, # the version chosen by upstream cabal.nix

  withHLS ? false,
}:

let
  # The toolings default to ghc966
  haskellPackagesDefault =
    (import sources.${ghcVersionDefault} { }).haskell.packages.${ghcVersionDefault};

  # GHC version to work with cabal is overridable
  haskellPackages = pkgs.haskell.packages.${ghcVersion};
  haskellPackages' = pkgs.haskellPackages;

  inherit (pkgs.haskell.lib)
    justStaticExecutables
    dontCheck
    ;
in

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # GHC dependent
    (lib.optional withHLS haskellPackages.haskell-language-server)
    (if ghcVersion == "ghc942" then haskell.compiler.ghc942 else haskellPackages.ghc)

    haskellPackagesDefault.retrie
    (justStaticExecutables (dontCheck (haskellPackagesDefault.callHackage "fourmolu" "0.12.0.0" { })))

    # Cabal version of haskellPackagesDefault is 3.12.
    # It doesn't support ghc later than 912.
    (
      if ghcVersion == "ghc9123" || ghcVersion == "ghc9141" then
        haskellPackages'
      else
        haskellPackagesDefault
    ).cabal-install

    haskellPackagesDefault.fix-whitespace
    haskellPackagesDefault.hlint
    haskellPackagesDefault.apply-refact
    haskellPackagesDefault.doctest
    haskellPackagesDefault.ghcid
    pkg-config
    zlib.dev
  ];
}
