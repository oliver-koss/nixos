final: prev: {
  ardopc = prev.callPackage ./ardopc.nix {};
  ardopc-init = prev.callPackage ./ardopc-init.nix {};
  status = prev.callPackage ./lcd-status.nix {};
  m365py = prev.callPackage ./m365py.nix {};
  jdownloader = prev.callPackage ./jdownloader {};
  fritzbox-exporter = prev.callPackage ./fritzbox {};
  aegis-cli = prev.callPackage ./aegis-cli {};
  reactionary = prev.callPackage ./apps/reactionary {};
  r0c = prev.callPackage ./apps/r0c {};
}
