{
  description = "Trigger the audial/visual bell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
  }: (
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        name = "bell";
        script = (pkgs.writeScriptBin name (builtins.readFile ./bell.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              prettier.enable = true;
              shellcheck.enable = true;
              shfmt.enable = true;
            };
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          inherit (checks.pre-commit-check) shellHook;
        };
        packages.default = pkgs.symlinkJoin {
          inherit name;
          paths = [script];
          buildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/${name}";
        };
      }
    )
  );
}
