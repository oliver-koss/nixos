{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, fritzconnection
, pbr
}:

buildPythonPackage rec {
  pname = "fritzcollectd";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fetzerch";
    repo = "fritzcollectd";
    rev = "v${version}";
    hash = "sha256-SheNVquzWO6w437YM1GN+Ifz7VWbl6xxfW4BIUeXD40=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    fritzconnection
    pbr
  ];

  pythonImportsCheck = [ "fritzcollectd" ];

  meta = with lib; {
    description = "A collectd plugin for monitoring AVM FRITZ!Box routers";
    homepage = "https://github.com/fetzerch/fritzcollectd";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
