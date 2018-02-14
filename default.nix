let
  hostPkgs = import <nixpkgs> {};
  nixpkgs = (hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "nixos-unstable";
    sha256 = "126701b11dx4rk9343ak7xl2sg5qr966jfj1n733jmvsgqc1di4l";
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
    src = null;
    shellHook = ''
    export NINJA_STATUS="[Built edge %f of %t in %e sec]"
    SOURCE_DATE_EPOCH=$(date +%s)
    '';
  }
