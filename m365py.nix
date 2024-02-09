{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "m365py";
  version = "unstable-2019-07-08";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "AntonHakansson";
    repo = "m365py";
    rev = "4e282209b3667f037012f57227da2505cadc8c57";
    hash = "sha256-0VhuSnGDoXDkTt9WaeTuI3bvEJmZ/ZqIl/V92y9oJBg=";
  };

  BuildInputs = [
    python3.pkgs.wheel
    python3.pkgs.bluepy
#    python3.pkgs.pip
  ];

  pythonImportsCheck = [ "m365py" ];

  meta = with lib; {
    description = "A lightweight python library to receive parsed BLE Xiaomi M365 scooter(Version=V1.3.8) messages using bluepy";
    homepage = "https://github.com/AntonHakansson/m365py";
    license = licenses.mit; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "m365py";
  };
}
