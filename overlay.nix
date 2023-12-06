final: prev: {
  pat = prev.callPackage ./pat.nix {};
  ardopc = prev.callPackage ./ardopc.nix {};
  ardopc-init = prev.callPackage ./ardopc-init.nix {};
  status = prev.callPackage ./lcd-status.nix {};
}
