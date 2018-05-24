let
  hostPkgs = import <nixpkgs> {};
  nixpkgs = (hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "nixos-18.03";
    sha256 = "1q32p61l2y8wcrc8q01k364xsmfpfygbxawwkby3dh199zyhwl6r";
  });
in
  with import nixpkgs {
    overlays = [(self: super:
    {
    }
    )];
  };
  stdenv.mkDerivation {
    name = "message";
    buildInputs = [
      cmake
      dpkg
      gcc
      libuuid
      ninja
      pkgconfig
      rpm
    ];
    hardeningDisable = [ "all" ];
    src = null;
    shellHook = ''
    export NINJA_STATUS="[Built edge %f of %t in %e sec]"
    SOURCE_DATE_EPOCH=$(date +%s)
    '';
  }
