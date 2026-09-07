# NixlyOS kernel

Gaming-kernel for NixOS, bygget på **siste stabile kernelrelease** (vanilla i bunn) med
CachyOS-patchene rebased oppå (`github:CachyOS/linux`-branchen `<major>/cachy`).
Samme oppskrift som CachyOS sitt offisielle kernel — ingen ytelsestriks utelatt:

| Tweak | Verdi |
|---|---|
| Scheduler | EEVDF + **BORE** |
| sched_ext | `SCHED_CLASS_EXT=y` — full støtte for **scx_lavd** m.fl. |
| Tick | **1000 Hz**, full tickless (`NO_HZ_FULL`) |
| Preempt | Full (`PREEMPT`) |
| Kompilator | clang + **thin-LTO**, `-O3` |
| Minne | Transparent hugepages = always |
| Nett | **BBR3** + FQ pacing |

## Varianter

| Pakke | Målgruppe |
|---|---|
| `linux-nixlyos` | Generic x86-64 — kjører på alt |
| `linux-nixlyos-v3` | x86-64-v3 (AVX2-generasjonen, default) |

## Bruk

```sh
./update.sh                  # hent siste stabile kernelrelease (hopper over rc)
nix build .#linux-nixlyos-v3 # bygg kernel
./cache.sh                   # bygg og cache begge variantene (GC-røtter i ./cache/)
nix flake check              # rask verifisering av config-tweaks
nix develop                  # devshell med kernelverktøy
```

## Caching

`./cache.sh` bygger begge kernels og fester dem som GC-røtter i `./cache/` —
de overlever `nix-collect-garbage` og gjenbygges aldri unødig (samme input =
samme store-path = instant). Til en annen maskin uten å bygge der:

```sh
nix copy --to ssh://bruker@maskin $(readlink cache/linux-nixlyos-v3)
```

Alternativt delt binærcache: `cachix push <navn> $(readlink cache/linux-nixlyos-v3)`.

`update.sh` finner siste stabile release-tag i `github:CachyOS/linux`
(vanilla-treet med CachyOS-patchene rebased, f.eks. `cachyos-7.2.3-2`),
skriver den inn i `flake.nix` og låser på nytt. rc-versjoner hoppes alltid over.
BORE-scheduleren ligger ikke i release-treet og legges på som patch fra
`github:CachyOS/kernel-patches`.

## NixOS

Enklest: bruk modulen — den setter kernel (v3), cachyos-settings-sysctls
(swappiness/dirty bytes/max_map_count m.m.), io-schedulere per disktype,
zram (zstd) og scx_lavd. Alt kan overstyres (`lib.mkDefault` overalt).

```nix
# flake-input: nixlyos-kernel.url = "path:/home/total/git/kernel_nixlyos";
imports = [ inputs.nixlyos-kernel.nixosModules.default ];
```

Manuelt alternativ:

```nix
boot.kernelPackages = pkgs.linuxPackagesFor
  inputs.nixlyos-kernel.packages.x86_64-linux.linux-nixlyos-v3;
services.scx = {
  enable = true;
  scheduler = "scx_lavd";
};
```

Merk: split lock-mitigering (som stjeler ytelse i enkelte spill) er allerede
slått av i selve kernel-treet — trengs ingen sysctl.

## Struktur

```
flake.nix            # inputs + outputs
update.sh            # bump til siste stabile kernelrelease
nix/version.nix      # leser kernelversjon fra kildetreet
nix/configfile.nix   # .config: CachyOS-config + tweaks, med verifisering
nix/kernel.nix       # bygger én variant (clang/thin-LTO + linuxManualConfig)
nix/variants.nix     # generic / v3
nix/module.nix       # NixOS-modul: runtime-tuning + scx_lavd
nix/shell.nix        # devshell
nix/tweaks/          # én fil per tweak-område (base, timing, perf, march)
```

Merk: Rust-støtte i kernelen er av (skjules uansett av Kconfig i
clang-LTO-oppsettet) — betyr kun at eksperimentelle rust-drivere uteblir.
