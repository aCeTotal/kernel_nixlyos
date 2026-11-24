{
  description = "NixlyOS kernels: CachyOS performance per CPU level and a hardened vanilla enterprise kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Siste stabile CachyOS-release.
    linux-src = {
      url = "github:CachyOS/linux/cachyos-7.3.5-2";
      flake = false;
    };

    # Enterprise starter fra kernel.org.
    linux-vanilla = {
      url = "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.3.6.tar.xz";
      flake = false;
    };

    # CachyOS sin distro-config.
    cachy-config = {
      url = "github:CachyOS/linux-cachyos";
      flake = false;
    };

    # BORE ligger som egen patch.
    cachy-patches = {
      url = "github:CachyOS/kernel-patches";
      flake = false;
    };

    # Drivere bygget med kjernen.
    xone = {
      url = "github:dlundqvist/xone/v0.5.8";
      flake = false;
    };
    xpadneo = {
      url = "github:atar-axis/xpadneo/v0.10.5";
      flake = false;
    };
    msi-ec = {
      url = "github:MControlSuite/msi-ec";
      flake = false;
    };

    # Panelets CA, eneste modulnøkkel.
    nixlyos-ca = {
      url = "file+https://cache.aceclan.no/api/v1/ca.pem";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      linux-src,
      linux-vanilla,
      cachy-config,
      cachy-patches,
      xone,
      xpadneo,
      msi-ec,
      nixlyos-ca,
    }:
    let
      system = "x86_64-linux";
      # Modulene arver denne allowUnfree.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      variants = import ./nix/variants.nix {
        inherit
          pkgs
          nixpkgs
          linux-src
          linux-vanilla
          cachy-config
          cachy-patches
          ;
        drivers = { inherit xone xpadneo msi-ec; };
        caCert = nixlyos-ca;
      };
    in
    {
      packages.${system} = {
        linux-nixlyos = variants.generic;
        linux-nixlyos-v3 = variants.v3;
        linux-nixlyos-server = variants.server;
        linux-nixlyos-enterprise = variants.enterprise;
        default = variants.v3;
      };

      # Config-tweaks verifisert uten kernelbygg.
      checks.${system} = {
        config-generic = variants.generic.configfile;
        config-v3 = variants.v3.configfile;
        config-server = variants.server.configfile;
        config-enterprise = variants.enterprise.configfile;
      };

      overlays.default = final: prev: {
        linuxPackages_nixlyos = final.linuxPackagesFor self.packages.${system}.linux-nixlyos;
        linuxPackages_nixlyos_v3 = final.linuxPackagesFor self.packages.${system}.linux-nixlyos-v3;
        linuxPackages_nixlyos_server = final.linuxPackagesFor self.packages.${system}.linux-nixlyos-server;
        linuxPackages_nixlyos_enterprise = final.linuxPackagesFor self.packages.${system}.linux-nixlyos-enterprise;
      };

      # Runtime-tuning for ytelseskjernen.
      nixosModules.default = import ./nix/module.nix self;

      devShells.${system}.default = import ./nix/shell.nix { inherit pkgs; };
    };
}
