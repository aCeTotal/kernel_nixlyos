{
  description = "NixlyOS gaming-kernel: siste stabile kernel + CachyOS-saus, BORE + sched_ext (scx_lavd), 1000Hz, full tickless/preempt, -O3, BBR3, thin-LTO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Siste stabile release (vanilla i bunn) med alle CachyOS-patcher + BORE i treet.
    # Oppdateres til siste stabile release-tag med ./update.sh (hopper over rc).
    linux-src = {
      url = "github:CachyOS/linux/cachyos-7.2.3-2";
      flake = false;
    };

    # CachyOS sin distro-config (linux-cachyos/config).
    cachy-config = {
      url = "github:CachyOS/linux-cachyos";
      flake = false;
    };

    # BORE-scheduleren ligger som egen patch (ikke i release-treet).
    cachy-patches = {
      url = "github:CachyOS/kernel-patches";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      linux-src,
      cachy-config,
      cachy-patches,
    }:
    let
      system = "x86_64-linux";
      # allowUnfree: nixpkgs' linuxPackagesFor gjenbruker kernel.stdenv for
      # out-of-tree-moduler, og stdenv-ens checkMeta arver DENNE instansens
      # config - uten allowUnfree nekter nedstroms nvidia-modulen aa evaluere.
      # Paavirker ikke kernelens drv-hash.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      variants = import ./nix/variants.nix {
        inherit
          pkgs
          nixpkgs
          linux-src
          cachy-config
          cachy-patches
          ;
      };
    in
    {
      packages.${system} = {
        linux-nixlyos = variants.generic;
        linux-nixlyos-v3 = variants.v3;
        default = variants.v3;
      };

      # Rask verifisering av at alle config-tweaks bet, uten full kernelbygging.
      checks.${system} = {
        config-generic = variants.generic.configfile;
        config-v3 = variants.v3.configfile;
      };

      overlays.default = final: prev: {
        linuxPackages_nixlyos = final.linuxPackagesFor self.packages.${system}.linux-nixlyos;
        linuxPackages_nixlyos_v3 = final.linuxPackagesFor self.packages.${system}.linux-nixlyos-v3;
      };

      # Runtime-tuning (cachyos-settings-sysctls, io-schedulere, zram, scx_lavd).
      nixosModules.default = import ./nix/module.nix self;

      devShells.${system}.default = import ./nix/shell.nix { inherit pkgs; };
    };
}
