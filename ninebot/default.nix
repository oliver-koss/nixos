{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, bleak
, bleak-retry-connector
, bluetooth-data-tools
, bluetooth-sensor-state-data
, callPackage
, black
, mypy
, python3
}:

buildPythonPackage rec {
  pname = "ninebot_ble";
  version = "0.0.6";
#  pyproject = true;
  format = "other";

  src = fetchFromGitHub {
    owner = "ownbee";
    repo = "ninebot-ble";
    rev = version;
    hash = "sha256-gA3VTs45vVpO0Iy8MbvvDf9j99vsFzrkADaJEslx6y0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    bleak
    bleak-retry-connector
    bluetooth-data-tools
    bluetooth-sensor-state-data
    (callPackage ./mi.nix {})
  ];

  passthru.optional-dependencies = {
    dev = [
      black
      mypy
    ];
  };

  postInstall = ''
    mkdir -p $out/${python3.sitePackages}
    cp -r ninebot_ble $out/${python3.sitePackages}/ninebot_ble
  '';

  pythonImportsCheck = [ "ninebot_ble" ];

  meta = with lib; {
    description = "Ninebot scooter BLE client";
    homepage = "https://github.com/ownbee/ninebot-ble";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
