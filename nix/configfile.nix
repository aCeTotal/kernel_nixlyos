# Bygger .config: CachyOS-distroconfig + våre tweaks, og verifiserer at de bet.
{
  stdenv,
  lib,
  src,
  configSrc,
  kernelVersion,
  tweaks,
  checks,
  commonMakeFlags,
  patches,
  bison,
  flex,
  perl,
  bc,
  openssl,
  pahole,
  zstd,
  elfutils,
  python3Minimal,
  rustc,
  rust-bindgen,
  rustPlatform,
}:
stdenv.mkDerivation {
  pname = "nixlyos-kernel-config";
  version = kernelVersion;
  inherit src patches;

  nativeBuildInputs = [
    bison
    flex
    perl
    bc
    openssl
    pahole
    zstd
    elfutils
    python3Minimal
    rustc
    rust-bindgen
  ];

  env.RUST_LIB_SRC = rustPlatform.rustLibSrc;

  makeFlags = commonMakeFlags;

  buildPhase = ''
    runHook preBuild

    cp ${configSrc}/linux-cachyos/config .config
    patchShebangs scripts/
    make $makeFlags olddefconfig
    scripts/config ${tweaks}
    make $makeFlags olddefconfig

    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    status=0
    for opt in ${toString checks}; do
      if ! grep -q "^CONFIG_$opt" .config; then
        echo "FEIL: CONFIG_$opt mangler i generert .config" >&2
        status=1
      fi
    done
    [ "$status" -eq 0 ]

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    cp .config $out
    runHook postInstall
  '';
}
