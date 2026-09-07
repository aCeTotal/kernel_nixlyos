# Devshell for kernelarbeid: verktøy for menuconfig, patching og feilsøking.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    ncurses
    pkg-config
    bison
    flex
    bc
    perl
    python3
    llvmPackages_latest.clang
    llvmPackages_latest.lld
    llvmPackages_latest.llvm
    pahole
  ];

  shellHook = ''
    echo "NixlyOS kernel-devshell"
    echo "  nix build .#linux-nixlyos      # generic (alle x86-64-CPUer)"
    echo "  nix build .#linux-nixlyos-v3   # x86-64-v3 (default)"
    echo "  nix build .#linux-nixlyos-v4   # x86-64-v4 (AVX-512-gen)"
    echo "  nix flake check                # verifiser config-tweaks (raskt)"
    echo "  ./update.sh                    # hent siste stabile kernelrelease"
  '';
}
