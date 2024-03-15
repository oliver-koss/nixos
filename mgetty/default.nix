{ lib
, stdenv
, fetchurl
, moreutils
}:

stdenv.mkDerivation rec {
  pname = "mgetty";
  version = "unstable-2014-01-29";

  src = fetchurl {
    url = "file:///etc/nixos/mgetty/mgetty-1.2.1.tar.gz";
    sha256 = "sha256-gg2XJPAgo+acszeJOgtjwtsWHa3LDgb8Edwp6x6Eoyw=";
  };



  meta = with lib; {
    description = "";
    homepage = "https://github.com/Distrotech/mgetty";
    changelog = "https://github.com/Distrotech/mgetty/blob/${src.rev}/ChangeLog";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "mgetty";
    platforms = platforms.all;
  };
}
