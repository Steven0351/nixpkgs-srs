{ 
  lib, stdenv, pkgs, writeScriptBin, fetchFromGitHub,
  homeDir ? throw "Must provide a home directory"
}:
let 
  version = "unstable";
  lunarvimRuntimeDir = "$out/share/lunarvim";
  lvimBin = writeScriptBin "lvim" ''
    #!/bin/sh
    export LUNARVIM_CONFIG_DIR=${homeDir}/.config/lvim
    export LUNARVIM_RUNTIME_DIR=${homeDir}/.nix-profile/share/lunarvim
    exec ${pkgs.neovim}/bin/nvim -u ${homeDir}/.nix-profile/share/lunarvim/init.lua "$@"
  '';
  lunarvim = stdenv.mkDerivation rec {
    name = "lunarvim-${version}";

    src = fetchFromGitHub {
      owner = "LunarVim";
      repo = "LunarVim";
      rev = "6770808bec1ffcada425ae514747f9380e3d3b8d";
      sha256 = "fHmvxAz9DqAh7pQ4l1OCQkAGSHDg2kNhDSgtngFEFI8=";
    };

    buildInputs = with pkgs; [
      git
    ];
    
    propagatedBuildInputs = [
      pkgs.tree-sitter
      pkgs.nodePackages.neovim
      pkgs.python39Packages.pynvim
      pkgs.ripgrep
      pkgs.fd
    ];

    buildPhase = ''
    echo "Do Nothing"
    '';

    installPhase = ''
      mkdir -p ${lunarvimRuntimeDir}/lvim 
      cp -r . ${lunarvimRuntimeDir}/lvim
    '';

    meta = with lib; {
      description = "An IDE Layer for Neovim 0.5.0+";
      homepage = "https://lunarvim.org";
      license = licenses.gpl3Only;
      platforms = platforms.all;
      maintainers = with maintainers; [ ChristianChiarulli ];
    };
  };
in pkgs.symlinkJoin {
  name = "lvim";
  paths = [ lvimBin pkgs.neovim ];
  propagatedBuildInputs = [
    lunarvim
  ];
}
