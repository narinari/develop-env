# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.system = "aarch64-linux";

  boot = {
    tmpOnTmpfs = true;
    initrd = {
      availableKernelModules = [ "usbhid" "usb_storage" ];
      kernelModules = [ ];
    };
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # Some gui programs need this
      "cma=128M"
    ];
  };
  boot.loader.grub.enable = false;
  # boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}