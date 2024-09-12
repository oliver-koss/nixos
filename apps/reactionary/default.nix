{ stdenv, fetchFromGitLab }:
{
  sddm-reactionary = stdenv.mkDerivation rec {
    domain = "opencode.net";
    pname = "reactionary";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/reactionary
    '';
    src = fetchFromGitLab {
      owner = "phob1an";
      repo = "reactionary";
      rev = "v${version}";
      sha256 = "0gx0am7vq1ywaw2rm1p015x90b75ccqxnb1sz3wy8yjl27v82yhb";
    };
  };
}
