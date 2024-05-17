{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fritz-exporter";
  version = "2.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pdreker";
    repo = "fritz_exporter";
    rev = "fritzexporter-v${version}";
    hash = "sha256-x5WCVDIKdreQCmVpiWbmVBNo42P5kSxX9dLMBKfZTWc=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    attrs
    defusedxml
    fritzconnection
    prometheus-client
    pyyaml
    requests
  ];

  pythonImportsCheck = [ "fritz_exporter" ];

  meta = with lib; {
    description = "Prometheus exporter for Fritz!Box home routers";
    homepage = "https://github.com/pdreker/fritz_exporter";
    changelog = "https://github.com/pdreker/fritz_exporter/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "fritz-exporter";
  };
}
