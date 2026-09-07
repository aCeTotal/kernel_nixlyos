#!/usr/bin/env bash
# Oppdaterer flake til siste stabile CachyOS-kernelrelease (hopper over rc).
set -euo pipefail
cd "$(dirname "$0")"

latest=$(curl -sf 'https://api.github.com/repos/CachyOS/linux/releases?per_page=30' |
  grep -oE '"tag_name": "cachyos-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+"' |
  grep -oE 'cachyos-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+' | sort -Vu | tail -1)

current=$(grep -oE 'cachyos-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+' flake.nix)

if [ "$latest" = "$current" ]; then
  echo "Allerede på siste stabile release: $current"
else
  echo "Oppdaterer $current -> $latest"
  sed -i "s|$current|$latest|" flake.nix
fi

nix flake update linux-src cachy-config
