final: prev: {
  waybar = prev.waybar.overrideAttrs (old: {
    version = "0.15.0-unstable-2026-09-18";
    src = prev.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "1687ec724a89756e79371784a2ba3f9700f8e5c6";
      hash = "sha256-OJBVQSIpW0Ozb3czGP3+TQyDC5BBqMQtx2asPsspFHo=";
    };
    buildInputs = (old.buildInputs or [ ]) ++ [ prev.modemmanager ];
    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dcava=disabled" ];
    doInstallCheck = false;
  });
}
