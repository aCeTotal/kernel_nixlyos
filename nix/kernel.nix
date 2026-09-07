# Setter sammen én kernelvariant: clang/thin-LTO-verktøykjede, .config og bygg.
{
  pkgs,
  nixpkgs,
  lib,
  src,
  configSrc,
  version,
  name,
  localVersion,
  march,
  patches,
}:
let
  llvmPackages = pkgs.llvmPackages_latest;
  stdenv = llvmPackages.stdenv;

  # thin-LTO krever lld og llvm-binutils; wrappede versjoner brekker kernel-linking.
  llvmFlags = [
    "LD=${lib.getExe' llvmPackages.lld "ld.lld"}"
    "AR=${lib.getExe' llvmPackages.llvm "llvm-ar"}"
    "NM=${lib.getExe' llvmPackages.llvm "llvm-nm"}"
  ];

  commonMakeFlags = import "${nixpkgs}/pkgs/os-specific/linux/kernel/common-flags.nix" {
    inherit lib stdenv;
    inherit (pkgs) buildPackages;
    extraMakeFlags = llvmFlags;
  };

  tweaks = lib.concatStringsSep " " (
    import ./tweaks/base.nix
    ++ import ./tweaks/timing.nix
    ++ import ./tweaks/perf.nix
    ++ march.flags
    ++ [
      "--set-str LOCALVERSION ${localVersion}"
      "-d LOCALVERSION_AUTO"
    ]
  );

  # Verifisering: bygget feiler hvis noen av disse mangler i ferdig .config.
  checks = [
    "SCHED_BORE=y"
    "SCHED_CLASS_EXT=y"
    "HZ=1000"
    "NO_HZ_FULL=y"
    "PREEMPT=y"
    "CC_OPTIMIZE_FOR_PERFORMANCE_O3=y"
    "TRANSPARENT_HUGEPAGE_ALWAYS=y"
    "LTO_CLANG_THIN=y"
    "DEFAULT_TCP_CONG=.bbr3."
    march.check
  ];

  configfile = pkgs.callPackage ./configfile.nix {
    inherit
      stdenv
      src
      configSrc
      tweaks
      checks
      commonMakeFlags
      patches
      ;
    kernelVersion = version;
  };
in
(pkgs.linuxManualConfig {
  inherit
    version
    src
    stdenv
    configfile
    ;
  modDirVersion = lib.versions.pad 3 "${version}${localVersion}";
  allowImportFromDerivation = true;
  extraMakeFlags = llvmFlags;
  kernelPatches = map (p: {
    name = builtins.baseNameOf p;
    patch = p;
  }) patches;
  isZen = true;
  features = {
    efiBootStub = true;
    ia32Emulation = true;
  };
}).overrideAttrs
  (prev: {
    pname = name;
    passthru = prev.passthru // {
      inherit configfile;
    };
  })
