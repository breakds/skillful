{ inputs, ... }:

let
  inherit (inputs) self nixpkgs crane advisory-db;
in {
  perSystem = { system, pkgs, lib, ... }: let
    craneLib = crane.mkLib pkgs;

    src = craneLib.cleanCargoSource ../.;

    commonArgs = {
      inherit src;
      strictDeps = true;
      buildInputs = [
        # Add additional build inputs here
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        pkgs.libiconv
      ];
    };

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  in {
    _module.args.pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    checks = {
      {{PROJECT_NAME_UNDERSCORE}}-clippy = craneLib.cargoClippy (commonArgs // { inherit cargoArtifacts; });

      {{PROJECT_NAME_UNDERSCORE}}-doc = craneLib.cargoDoc (commonArgs // {
        inherit cargoArtifacts;
        env.RUSTDOCFLAGS = "--deny warnings";
      });

      {{PROJECT_NAME_UNDERSCORE}}-fmt = craneLib.cargoFmt {
        inherit src;
      };

      {{PROJECT_NAME_UNDERSCORE}}-toml-fmt = craneLib.taploFmt {
        src = lib.sources.sourceFilesBySuffices src [ ".toml" ];
      };

      {{PROJECT_NAME_UNDERSCORE}}-deny = craneLib.cargoDeny {
        inherit src;
      };

      {{PROJECT_NAME_UNDERSCORE}}-nextest = craneLib.cargoNextest (commonArgs // {
        inherit cargoArtifacts;
        partitions = 1;
        partitionType = "count";
        cargoNextestPartitionsExtraArgs = "--no-tests=pass";
      });
    };

    devShells.default = let
      pythonEnv = pkgs.python3.withPackages (ps: with ps; [
        numpy
        # Add python dependencies here
      ]);
    in craneLib.devShell {
      checks = self.checks."${system}";
      packages = with pkgs; [
        pythonEnv
        maturin
      ];
    };

    # Expose the python package
    packages.default = pkgs.python3Packages.callPackage ./package.nix {};
  };
}
