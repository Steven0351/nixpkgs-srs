{ lib, stdenv, pkgs, fetchFromGitHub }:
let 
  version = "unstable";
  lunarvimRuntimeDir = "$out/share/lunarvim";
in stdenv.mkDerivation rec {
  name = "lunarvim-${version}";

  src = fetchFromGitHub {
    owner = "LunarVim";
    repo = "LunarVim";
    rev = "6770808bec1ffcada425ae514747f9380e3d3b8d";
    sha256 = "fHmvxAz9DqAh7pQ4l1OCQkAGSHDg2kNhDSgtngFEFI8=";
  };

  buildInputs = with pkgs; [
    tree-sitter
    nodePackages.neovim
    neovim
    python39Packages.pynvim
    ripgrep
    fd
    git
  ];

  postInstall = ''
  mkdir -p ${lunarvimRuntimeDir}/lvim 
  cp -r . ${lunarvimRuntimeDir}/lvim

  cat > '$out/bin/lvim' << EOF
  #!/bin/sh
  export LUNARVIM_CONFIG_DIR=$HOME/.config/lvim
  export LUNARVIM_RUNTIME_DIR=${lunarvimRuntimeDir}
  exec nvim -u ${lunarvimRuntimeDir}/init.lua $@
  EOF

  chmod +x $out/bin/lvim

  "$out/bin/lvim" --headless \
    -c 'autocmd User PackerComplete quitall' \
    -c 'PackerSync'
  '';

  meta = with lib; {
    description = "An IDE Layer for Neovim 0.5.0+";
    homepage = "https://lunarvim.org";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ ChristianChiarulli ];
  };
}
