{ fetchFromGitHub
, buildGoModule
, lib
}:

buildGoModule rec {
  pname = "pat";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "la5nta";
    repo = "pat";
    rev = "v${version}";
    hash = "sha256-wNWqqGc4mf3z0ejMpU+jWhqCbjNJ2b6+pbBjDYKwKK8=";
  };

  vendorHash = "sha256-m5yb6+TfRApw0ZROx9ZA3RPiKV+1DHo/73CNQpIfMlU=";

  meta = with lib; {
    description = "A cross-platform Winlink client written in Go";
    homepage = "https://github.com/la5nta/pat/";
    license = licenses.mit;
    maintainers = with maintainers; [ oliver-koss ];
  };
}
