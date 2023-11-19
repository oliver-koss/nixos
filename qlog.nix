{ fetchFromGitHub
, qtbase
, stdenv
, wrapQtAppsHook
, qmake
, qtcharts
#, qtwebenginewidgets
, qtwebengine
, qtserialport
, qtwebchannel
, hamlib
, qtkeychain
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "qlog";
  version = "0.29.2";

  src = fetchFromGitHub {
    owner = "foldynl";
    repo = "QLog";
    rev = "v${version}";
    hash = "sha256-g7WgFQPMOaD+3YllZqpykslmPYT/jNVK7/1xaPdbti4=";
    fetchSubmodules = true;
  };

  env.NIX_LDFLAGS = "-lhamlib";

  buildInputs = [
    qtbase
    qtcharts
#    qtwebenginewidgets
    qtwebengine
    qtserialport
    qtwebchannel
    hamlib
    qtkeychain
  ];

  nativeBuildInputs = [
    wrapQtAppsHook
    qmake
    pkg-config
  ];
}
