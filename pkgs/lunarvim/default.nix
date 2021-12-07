{ lib, stdenv, pkgs, fetchFromGitHub }:
let 
  version = "unstable";
  lunarvimRuntimeDir = "$out/share/lunarvim";
  lunarvimConfigDir = builtins.getEnv "HOME" + "/.config/lvim";
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
  export LUNARVIM_CONFIG_DIR=${lunarvimConfigDir}
  export LUNARVIM_RUNTIME_DIR=${lunarvimRuntimeDir}
  exec nvim -u ${lunarvimRuntimeDir}/init.lua $@
  EOF

  chmod +x $out/bin/lvim

  # if [ ! -f ${lunarvimConfigDir}/config.lua ]; then
  #   cp "${lunarvimRuntimeDir}/lvim/utils/installer/config.example.lua" "${lunarvimConfigDir}/config.lua"
  # fi

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
