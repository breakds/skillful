{ inputs, ... }:

let
  nixpkgs = inputs.nixpkgs;
in {
  perSystem = { system, pkgs, ... }: {
    _module.args.pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    devShells.default = pkgs.mkShell {
      name = "{{PROJECT_NAME}}";

      packages = with pkgs; [
        nodejs
        pnpm
        # Add additional dev tools here
      ];

      shellHook = ''
        export PS1="$(echo -e '\uf308') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} ({{PROJECT_NAME}}) \\$ \[$(tput sgr0)\]"
      '';
    };
  };
}
