# CachyOS-innstillinger for ytelseskjernen.
self:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelPackages = lib.mkDefault (
    pkgs.linuxPackagesFor self.packages.x86_64-linux.linux-nixlyos-v3
  );

  # Verdier fra cachyos-settings (70-cachyos-settings.conf).
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.page-cluster" = 0;
    "kernel.nmi_watchdog" = 0;
    "kernel.unprivileged_userns_clone" = 1;
    "net.core.netdev_max_backlog" = 4096;
    "fs.file-max" = 2097152;
    # SteamOS-verdien; Proton/spill med mange minne-mappings trenger denne.
    "vm.max_map_count" = 2147483642;
  };

  # io-scheduler per disktype + cpu_dma_latency-tilgang for audio-gruppen
  # (60-ioschedulers.rules og 99-cpu-dma-latency.rules fra cachyos-settings).
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
    DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
  '';

  # zram med zstd er CachyOS-standard.
  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = lib.mkDefault "zstd";
  };
}
