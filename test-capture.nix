{ inputs, config, pkgs, lib, ... }@args:
let
  # Get den.lib from the config
  denLib = config.den.lib;

  # den-diagram library
  diagram = inputs.den-diagram.lib { inherit lib; };

  # Capture the entire fleet
  fleetCapture = denLib.capture.captureFleet { };

  # Project onto host tx1c7
  g = diagram.projectScope { inherit fleetCapture; kind = "host"; name = "tx1c7"; };
in
{
  perSystem = { pkgs, ... }: {
    packages.test-den-diagram = pkgs.writeText "test-den-diagram" (diagram.toMermaid g);
  };
}