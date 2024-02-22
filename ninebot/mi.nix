{ lib
, buildPythonPackage
, bluepy
, setuptools
, wheel
, fetchFromGitHub
, callPackage
, cryptography
}:

buildPythonPackage rec {
  pname = "miauth";
  version = "release";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dnandha";
    repo = "miauth";
    rev = version;
    hash = "sha256-+aoY0Eyd9y7xQTA3uSC6YIZisViilsHlFaOXmhPMcBY=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    bluepy
     (callPackage ./crypto_36.nix {})
    cryptography
  ];

  pythonImportsCheck = [ "miauth" ];

  postPatch = ''
    sed "s|cryptography.*|cryptography|g" -i requirements.txt
  '';

  meta = with lib; {
    description = "Authenticate and interact with Xiaomi devices over BLE";
    homepage = "https://github.com/dnandha/miauth";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "miauth";
  };
}
