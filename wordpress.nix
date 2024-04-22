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




    
  wwp386 = (fetchTheme {
    name = "wp386";
    version = "1.1";
    hash = "sha256-FLoiykImurF1YmPhuzqODIFf6isusWe46RG+VnBCAEI=";
  });

  wp386 = pkgs.stdenv.mkDerivation rec {
    name = "wp386";
    version = "1.1";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/theme/wp386.1.1.zip";
      hash = "sha256-FLoiykImurF1YmPhuzqODIFf6isusWe46RG+VnBCAEI=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  retro = pkgs.stdenv.mkDerivation rec {
    name = "retro";
    version = "0.6";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/theme/retrogeek.0.6.zip";
      hash = "sha256-FLoiykImurF1YmPhuzqODIFf6isusWe46RG+VnBCAEI=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };



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
          inherit wp386;
          inherit retro;
        };
          settings = {
            WPLANG = "en_GB";
          };
      };
    };
  };
}
