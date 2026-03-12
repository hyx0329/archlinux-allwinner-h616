# This file is only tested on ArchLinux with Nix installed.
# Currently serves as an overlay on the existing components.
let
  # unstable, 2026-03-06
  nixpkgs_ball = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/917fec990948658ef1ccd07cef2a1ef060786846";
    sha256 = "1x3hmj6vbza01cl5yf9d0plnmipw3ap6y0k5rl9bl11fw7gydvva";
  };

  pkgs = import nixpkgs_ball { config = { allowUnfree = true; }; overlays = [ ]; };

  # magic!
  # packages here are cross built for aarch64, to create a target environment.
  # only useful when cross building packages for nixos
  # pkgs' = pkgs.pkgsCross.aarch64-multiplatform;
  # packages here are building dependencies running on the host machine, aka build tools
  pkgs'build = pkgs.pkgsCross.aarch64-multiplatform.buildPackages;


  # Package overrides
  sunxi-tools = pkgs.sunxi-tools.overrideAttrs (finalAttrs: previousAttrs: {
      version = "unstable-2024-06-13";
      src = pkgs.fetchFromGitHub {
          owner = "linux-sunxi";
          repo = "sunxi-tools";
          rev = "df60a46e38a840b5758c02433d7d85ad08361930";
          hash = "sha256-EepHEFNlW1LGtFlb3PNrtXXZiiBNEoZY+S9fQFQkiLA=";
        };
    });

  # Dependency lists
  u-boot-build-dependencies = [
    # u-boot known build dependencies, not an inclusive list yet
    pkgs.python312
    pkgs.python312Packages.setuptools
    pkgs.swig
    pkgs.ncurses
    pkgs.bison
    pkgs.flex
  ];

  cross-compiler = pkgs'build.gcc;
in

pkgs.mkShell {
  packages = [
    # basics
    pkgs.cacert # required for TLS in pure environment
    pkgs.git
    pkgs.curl
    pkgs.gnutls

    # the cross compiler
    cross-compiler

    # testing utilities
    sunxi-tools
  ] ++ u-boot-build-dependencies;

  # Set the correct cross compiler prefix, which can be found by inspecting `pkgs'build.gcc`
  shellHook = ''
    export CROSS_COMPILE=${cross-compiler.targetPrefix}
    '';
}
