final: prev: {
  thinkfan-tui = prev.rustPlatform.buildRustPackage rec {
    pname = "thinkfan-tui";
    version = "0.3.1";
    src = prev.fetchFromGitHub {
      owner = "karjonas";
      repo = "thinkfan-tui";
      rev = "0.3.1";
      hash = "sha256-wta7TgRczi5xec2xcT29TWa8z8O4Mas3FMuQHMY069Q=";
    };
    cargoLock.lockFile = ./thinkfan-tui.Cargo.lock;
    postPatch = ''cp ${./thinkfan-tui.Cargo.lock} Cargo.lock'';
    meta.mainProgram = "thinkfan-tui";
  };
}
