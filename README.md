# NixlyOS kernel

Fire kerneler for NixlyOS, alle på siste stabile kernel og alle låst ned:
modulsignatur er påkrevd, lockdown står fast i `confidentiality`, og dvale
fungerer med signert bilde.

| Pakke | Hva |
|---|---|
| `linux-nixlyos-v3` | Ytelse, x86-64-v3 (AVX2): alle maskiner som kan |
| `linux-nixlyos` | Samme kernel for CPU-er uten AVX2 |
| `linux-nixlyos-server` | Server: vanilla og herdet, for alle typer tjenere |
| `linux-nixlyos-enterprise` | Vanilla, slank og herdet |

**Ytelse:** CachyOS-taggen pluss kernel.org sine nyere stabilpatcher, BORE,
1000 Hz, full tickless og preempt, clang thin-LTO `-O3`, BBR3, NTSYNC. xone,
xpadneo og msi-ec (med viftekurver og firmware-fallback) ligger i treet.
sched_ext er bygget inn, men lockdown stopper planleggere som leser
kjerneminne, som scx_lavd.

**Server:** vanilla fra kernel.org med CachyOS sin brede distro-config for
maskinvare, herdet som enterprise (`nix/tweaks/hardening.nix`) men uten kCFI,
så NVIDIA-drevne GPU-tjenere virker. EEVDF,
`PREEMPT_LAZY` og 1000 Hz gir gjennomstrømning for web og fil og maks 1 ms
forsinkelse for spilltjenere; THP `madvise`, BBR + FQ, `-O2` og thin-LTO.
Ikke RT: PREEMPT_RT bytter gjennomstrømning mot garantert latens, som bare
harde sanntidsoppgaver trenger.

**Enterprise:** vanilla fra kernel.org, `defconfig` + `hardening.config` +
`nix/tweaks/hardening.nix` (kCFI, init_on_free, streng IOMMU, ingen kexec,
`/dev/mem`, io_uring eller debugfs). Kun drivere for vanlige
bedriftsmaskiner og VM-er.

## Signering

Ingen privat nøkkel finnes i bygget. `nixlyos-ca` er Nixly-panelets CA, bygget
inn som eneste betrodde modulnøkkel. Panelet signerer moduler, kernel og
systemd-boot når en release består sjekkene. Etter rotasjon av CA i panelet:

```sh
nix flake update nixlyos-ca
```

## Bruk

```sh
./update.sh                          # CachyOS-tag, stabilpatcher og vanilla til siste
nix build .#linux-nixlyos-v3         # bygg én kernel
./cache.sh                           # bygg alle, GC-røtter i ./cache/
nix flake check                      # verifiser alle config-tweaks
nix develop                          # kernelverktøy
```

`update.sh` slår sammen filer CachyOS også har endret tre-veis og skriver
`nix/stable.nix` og `nix/stable-fixup.patch`.

## Struktur

```
flake.nix             inputs og outputs
update.sh             oppdaterer alle kernelkilder
nix/variants.nix      desktop, server og enterprise
nix/kernel.nix        én kernel: clang thin-LTO + linuxManualConfig
nix/configfile.nix    grunnconfig + tweaks, verifisert
nix/tweaks/           ytelse, server, herding, signatur og lockdown
nix/enterprise/       desktop og maskinvare for enterprise
nix/patches/          drivere i treet og sikker dvale
nix/drivers.nix       kopierer xone, xpadneo og msi-ec inn
nix/module.nix        runtime-tuning for ytelseskjernen
```
