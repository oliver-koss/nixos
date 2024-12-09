{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  dotnetPackages,
  msbuild,
  makeWrapper,
  mono,
  libGL,
  gtk2,
}:

stdenvNoCC.mkDerivation rec {
  pname = "nbt-explorer";
  version = "2.8.0-win";

  src = fetchFromGitHub {
    owner = "jaquadro";
    repo = "NBTExplorer";
    rev = "v${version}";
    hash = "sha256-uOoELun0keFYN1N2/a1IkCP1AZQvfDLiUdrLxxrhE/A=";
  buildCommand = ''
    touch $out
  '';
  };

  meta = with lib; {
    description = "A graphical NBT editor for all Minecraft NBT data sources";
    homepage = "https://github.com/jaquadro/NBTExplorer.git";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "nbt-explorer";
    platforms = platforms.all;
  };
}
