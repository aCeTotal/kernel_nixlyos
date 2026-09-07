#!/usr/bin/env bash
# Bygger begge kernelvariantene og fester dem som GC-røtter i ./cache/,
# slik at de overlever nix-collect-garbage og alltid er klare til bruk.
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p cache
nix build .#linux-nixlyos -o cache/linux-nixlyos
nix build .#linux-nixlyos-v3 -o cache/linux-nixlyos-v3

echo
echo "Cachet:"
for l in cache/*; do
  echo "  $l -> $(readlink "$l")"
done
echo
echo "Kopier til annen maskin (bygger ingenting der):"
echo "  nix copy --to ssh://bruker@maskin \$(readlink cache/linux-nixlyos-v3)"
