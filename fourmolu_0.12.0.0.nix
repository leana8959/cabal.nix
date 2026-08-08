{ mkDerivation, aeson, ansi-terminal, array, base, binary
, bytestring, Cabal-syntax, containers, deepseq, Diff, directory
, fetchzip, file-embed, filepath, ghc-lib-parser, hspec
, hspec-discover, hspec-megaparsec, lib, megaparsec, MemoTrie, mtl
, optparse-applicative, path, path-io, pretty, process, QuickCheck
, scientific, syb, temporary, text, th-env, yaml
}:
mkDerivation {
  pname = "fourmolu";
  version = "0.12.0.0";
  src = fetchzip {
    url = "https://hackage.haskell.org/package/fourmolu-0.12.0.0/fourmolu-0.12.0.0.tar.gz";
    sha256 = "1lyvj0a6nhfkpyad0jrwqbiilv4s8fn57597b4xc635vrsbbrfya";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson ansi-terminal array base binary bytestring Cabal-syntax
    containers deepseq Diff directory file-embed filepath
    ghc-lib-parser megaparsec MemoTrie mtl scientific syb text yaml
  ];
  executableHaskellDepends = [
    base containers directory filepath ghc-lib-parser
    optparse-applicative text th-env yaml
  ];
  testHaskellDepends = [
    base Cabal-syntax containers Diff directory filepath ghc-lib-parser
    hspec hspec-megaparsec path path-io pretty process QuickCheck
    temporary text
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/fourmolu/fourmolu";
  description = "A formatter for Haskell source code";
  license = lib.meta.getLicenseFromSpdxId "BSD-3-Clause";
  mainProgram = "fourmolu";
}
