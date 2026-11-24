# Én kernel: clang thin-LTO, config, bygg.
{
  pkgs,
  nixpkgs,
  lib,
  src,
  version,
  name,
  localVersion,
  patches,
  vendorDrivers,
  caCert,
  baseConfig,
  tweaks,
  checks,
  absent ? [ ],
}:
let
  llvmPackages = pkgs.llvmPackages_latest;
  stdenv = llvmPackages.stdenv;

  # Wrappede binutils brekker thin-LTO.
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

  configfile = pkgs.callPackage ./configfile.nix {
    inherit
      stdenv
      src
      baseConfig
      commonMakeFlags
      patches
      vendorDrivers
      absent
      ;
    kernelVersion = version;
    tweaks = lib.concatStringsSep " " (
      tweaks
      ++ import ./tweaks/security.nix caCert
      ++ [
        "--set-str LOCALVERSION ${localVersion}"
        "-d LOCALVERSION_AUTO"
      ]
    );
    checks = checks ++ [
      "SECURITYFS=y"
      "MODULE_SIG_FORCE=y"
      "LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY=y"
      "HIBERNATION=y"
    ];
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
  features = {
    efiBootStub = true;
    ia32Emulation = true;
  };
}).overrideAttrs
  (prev: {
    pname = name;
    postPatch = (prev.postPatch or "") + vendorDrivers;
    passthru = prev.passthru // {
      inherit configfile caCert;
    };
  })
