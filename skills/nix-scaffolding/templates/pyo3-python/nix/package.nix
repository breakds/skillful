{
  stdenv,
  lib,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  rustPlatform,
  numpy,
}:

buildPythonPackage rec {
  pname = "{{PROJECT_NAME}}";
  version = "0.1.0";
  format = "pyproject";

  src = lib.cleanSourceWith {
    filter = name: type: ! (( type == "regular" ) && lib.hasSuffix ".nix" (baseNameOf name));
    src = lib.cleanSource ../.;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # Update after first build
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  propagatedBuildInputs = [
    # Add python runtime dependencies here
  ];

  pythonImportsCheck = [ "{{PROJECT_NAME_UNDERSCORE}}" ];
}
