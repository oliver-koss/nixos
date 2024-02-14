{ cryptography, fetchPypi, rustPlatform }: cryptography.overrideAttrs(p: rec {
  version = "36.0.0";
  src = fetchPypi {
    inherit (p) pname;
    inherit version;
    hash = "sha256-Uvdp7LTvOYZXGa7cZ7S36uFnuvpI28KibdNvpWRgUH8=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    sourceRoot = "${p.pname}-${version}/${p.cargoRoot}";
    name = "${p.pname}-${version}";
    hash = "sha256-Y6TuW7AryVgSvZ6G8WNoDIvi+0tvx8ZlEYF5qB0jfNk=";
  };

  pytestCheckPhase = "true";
})
