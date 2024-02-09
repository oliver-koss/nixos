final: prev: {
  ardopc = prev.callPackage ./ardopc.nix {};
  ardopc-init = prev.callPackage ./ardopc-init.nix {};
  status = prev.callPackage ./lcd-status.nix {};
  m365py = prev.callPackage ./m365py.nix {};
  jdownloader = prev.callPackage ./jdownloader {};
}
