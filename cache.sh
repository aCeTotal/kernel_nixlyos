#!/usr/bin/env bash
# Fester alle kernels som GC-røtter.
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p cache
for kernel in linux-nixlyos linux-nixlyos-v3 linux-nixlyos-v4 linux-nixlyos-enterprise; do
  nix build ".#$kernel" -o "cache/$kernel"
done

echo
echo "Cachet:"
for l in cache/*; do
  echo "  $l -> $(readlink "$l")"
done
