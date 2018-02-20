let
  hostPkgs = import <nixpkgs> {};
  nixpkgs = (hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "nixos-unstable";
    sha256 = "1p0xxyz30bd2bg0wrfviqgsskz00w647h0l2vi33w90i42k8r3li";
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
