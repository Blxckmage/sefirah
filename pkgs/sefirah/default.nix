{
  lib,
  python3Packages,
  imagemagick,
}:
let
  pyproject = lib.importTOML ./pyproject.toml;
in
python3Packages.buildPythonApplication {
  pname = pyproject.project.name;
  version = pyproject.project.version;
  src = ./.;

  format = "pyproject";
  nativeBuildInputs = [ python3Packages.setuptools ];

  checkPhase = ''
    python -m unittest discover -s tests -t .
  '';

  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [ imagemagick ])
  ];

  meta = {
    description = "Sefirah command line tools";
    mainProgram = "sefirah";
  };
}
