with (import <nixpkgs> {});

python3.withPackages(p: [ (python3.pkgs.callPackage ./. {}) ])
