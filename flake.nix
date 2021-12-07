{
  description = "My custom packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, flake-utils, nixpkgs }: {

    overlay = final: prev: {
        inherit (self.packages.${final.system})
          lunarvim;
    };

    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    # defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

  } // flake-utils.lib.eachSystem [
    "x86_64-darwin"
    "aarch64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ] (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        allowBroken = true;
        allowUnsupportedSystem = true;
      };
      version = "999-unstable";
    in {
      packages = rec {
        lunarvim = pkgs.callPackage ./pkgs/lunarvim {};
      };
    }
  );
}
