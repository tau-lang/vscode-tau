{
  description = "vscode-tau flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.pre-commit.flakeModule];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
        };
        devDependencies = with pkgs; [
          nodejs_26
          vsce
        ];
      in
        with pkgs; {
          pre-commit.settings.hooks = {
            alejandra.enable = true;
          };
          devShells.default = pkgs.mkShell {
            buildInputs = devDependencies;
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };
          packages.default = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "tau-lang";
              publisher = "tau-lang";
              version = "0.0.1";
              sha256 = "sha256-OATAgYRcjFiGg9w1WtY8gpW8+SStP4JZqe3f8//Y0+w=";
            };

            meta = {
              changelog = "https://codeberg.org/tau-lang/vscode-tau/src/branch/main/CHANGELOG.md";
              description = "Java Platform Extension for Visual Studio Code";
              downloadPage = "https://marketplace.visualstudio.com/items?itemName=tau-lang.tau";
              homepage = "https://codeberg.org/tau-lang/vscode-tau/";
              license = lib.licenses.eupl12;
              maintainers = [lib.maintainers.kiyotoko];
            };
          };
        };
    };
}
