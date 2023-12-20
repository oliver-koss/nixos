{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "m365py";
  version = "unstable-2019-07-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AntonHakansson";
    repo = "m365py";
    rev = "4e282209b3667f037012f57227da2505cadc8c57";
    hash = "sha256-0VhuSnGDoXDkTt9WaeTuI3bvEJmZ/ZqIl/V92y9oJBg=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "m365py" ];

  meta = with lib; {
    description = "A lightweight python library to receive parsed BLE Xiaomi M365 scooter(Version=V1.3.8) messages using bluepy";
    homepage = "https://github.com/AntonHakansson/m365py.git";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "m365py";
  };
}
