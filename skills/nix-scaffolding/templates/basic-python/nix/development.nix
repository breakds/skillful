{ inputs, ... }:

let
  self = inputs.self;
  nixpkgs = inputs.nixpkgs;
in {
  flake.overlays.dev = nixpkgs.lib.composeManyExtensions [
    (final: prev: {
      # Add overlayed packages here, for example:
      # my-tool = final.callPackage ./pkgs/my-tool {};
      #
      # For python packages:
      # pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      #   (py-final: py-prev: {
      #     my-python-pkg = py-final.callPackage ./pkgs/my-python-pkg {};
      #   })
      # ];
    })
  ];

  perSystem = { system, pkgs, ... }: {
    _module.args.pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ self.overlays.dev ];
    };

    devShells.default = pkgs.mkShell {
      name = "{{PROJECT_NAME}}";

      packages = with pkgs; [
        (python3.withPackages (p: with p; [
          # Add python dependencies here
        ]))
        basedpyright
        ruff
      ];

      shellHook = ''
        export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} ({{PROJECT_NAME}}) \\$ \[$(tput sgr0)\]"
      '';
    };
  };
}
