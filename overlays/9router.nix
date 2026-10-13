# 9router ahead of nixpkgs-unstable (which still ships 0.5.75 while the
# gateway prompts for 0.5.99). Defined fresh instead of overrideAttrs so
# the npm-deps prefetch tracks the new src; drop this once nixpkgs catches
# up. Regenerate 9router-package-lock.json on bumps:
#   npm install --package-lock-only --ignore-scripts (devDeps stripped first)
final: prev: {
  _9router = prev.buildNpmPackage (finalAttrs: {
    __structuredAttrs = true;

    pname = "9router";
    version = "0.5.99";

    src = prev.fetchzip {
      url = "https://registry.npmjs.org/9router/-/9router-${finalAttrs.version}.tgz";
      hash = "sha256-uz1EiuxtYbWANgMsYO8VdDJVtiMyiJPCScLOOkYhNjQ=";
    };

    npmDepsHash = "sha256-R3RFTB7Trm75fbVsCtFo+wb/jRTrIG4ZC5kKDQdQHKo=";

    postPatch = ''
      ${prev.lib.getExe' prev.nodejs "node"} --eval '
        const pkg = require("./package.json");
        delete pkg.devDependencies;
        require("fs").writeFileSync("package.json", JSON.stringify(pkg, null, 2));
      '

      cp ${./9router-package-lock.json} package-lock.json
    '';

    dontNpmBuild = true;

    npmFlags = [ "--ignore-scripts" ];

    passthru.updateScript = prev.nix-update-script { };

    meta = prev._9router.meta // {
      changelog = "https://github.com/decolua/9router/releases/tag/v${finalAttrs.version}";
    };
  });
}
