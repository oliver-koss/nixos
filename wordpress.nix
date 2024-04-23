{ config, lib, pkgs, ... }:

  let

  fetchPackage = { name, version, hash, isTheme }:
    pkgs.stdenv.mkDerivation rec {
      inherit name version hash;
      src = let type = if isTheme then "theme" else "plugin";
      in pkgs.fetchzip {
        inherit name version hash;
        url = "https://downloads.wordpress.org/${type}/${name}.${version}.zip";
      };
      installPhase = "mkdir -p $out; cp -R * $out/";
    };

  fetchPlugin = { name, version, hash }:
    (fetchPackage {
      name = name;
      version = version;
      hash = hash;
      isTheme = false;
    });

  fetchTheme = { name, version, hash }:
    (fetchPackage {
      name = name;
      version = version;
      hash = hash;
      isTheme = true;
    });


  retro = pkgs.stdenv.mkDerivation rec {
    name = "retro";
    version = "0.6";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/theme/retrogeek.0.6.zip";
      hash = "sha256-FLoiykImurF1YmPhuzqODIFf6isusWe46RG+VnBCAEI=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  smntcs-retro = (fetchTheme {
    name = "smntcs-retro";
    version = "43";
    hash = "sha256-6i5ASHcXMoAK7v7G4d9nbLR5zNTceItNppHB7cB7Bgo=";
  });



  in {

  services = {
    nginx.virtualHosts."blog.oliver-koss.at" = {
      enableACME = true;
      forceSSL = true;
    };

    wordpress = {
      webserver = "nginx";
      sites."blog.oliver-koss.at" = {
#        languages = [ pkgs.wordpressPackages.languages.en_GB ];
        themes = {
          inherit smntcs-retro;
        };
          settings = {
            WPLANG = "en_GB";
          };
      };
    };
  };
}
