# Kernelvariantene: generic (alle x86-64) og v3.
{
  pkgs,
  nixpkgs,
  linux-src,
  cachy-config,
  cachy-patches,
}:
let
  inherit (pkgs) lib;
  version = import ./version.nix {
    inherit lib;
    src = linux-src;
  };
  march = import ./tweaks/march.nix;

  patches = [
    "${cachy-patches}/${lib.versions.majorMinor version}/sched/0001-bore-cachy.patch"
  ];

  mkKernel =
    {
      name,
      localVersion,
      march,
    }:
    import ./kernel.nix {
      inherit
        pkgs
        nixpkgs
        lib
        version
        name
        localVersion
        march
        patches
        ;
      src = linux-src;
      configSrc = cachy-config;
    };
in
{
  generic = mkKernel {
    name = "linux-nixlyos";
    localVersion = "-nixlyos";
    march = march.generic;
  };
  v3 = mkKernel {
    name = "linux-nixlyos-v3";
    localVersion = "-nixlyos-v3";
    march = march.v3;
  };
}
