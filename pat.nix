{fetchFromGithub
, buildGoModule
}:

buildGoModule rec {
  pname = "pat";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "la5nta";
    repo = "pat";
    rev = "v${version}";
    hash = "";
  };

subPackages = ["cmd"];
}
