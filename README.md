# `cabal.nix`

This is a simple Nix developer environment for [hacking on Cabal](https://github.com/haskell/cabal/blob/master/CONTRIBUTING.md).

The most convenient way to use it is to have [`direnv` hooked into your shell](https://direnv.net/docs/hook.html) and a `.envrc` in the root of your `cabal` checkout that looks like:

The pins are added with the help of <https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=ghc>.

```bash
nix-shell <path to this repo> --argstr ghcVersion "ghcxxx" # use a custom ghc version you want
```
