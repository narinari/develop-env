# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./nixops/hardware/rpi4.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "silk"; # Define your hostname.
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaTFqajQTj2lgwi850i2SxGhbRMksEB3JGG9T0xlADzf//2P7pZ2SqwOA1Xj5Vi4JvcI9PK+iB4hGe+9YFx0N6DohRtWLcG8zX4pu93muEO+ZcXJ839NcFeut71PGacKIhXiw3FH7/sTyN+Jxt1msrEm1IhpqiLP4BaAUf/CvqO8vW9Qxi9vq0H27BZWxerTWE5YvvW/ftK2aCFRprnX1cfsDfitDGVqD+09i/Kr/miqOuPzH7G6Y6O6paiSZIixKSj8kl250ka0nBSSPEKTBlQEV3iybcDusqZiWz4zwwhZe+g0KxyO1GvT8O8sFzO91u+nLQM3cWbc/BbmUhu3F1w92oVicfHNAiZc1JN73nq3QOyVwBhsX3L4jBQfelEsg8MJTwTvZBtUjx+/d/njDVGSKcYyh6Y5d12socPv5D9YBuCQi3nY6oyIA5QdyloUK73FAmII1D3s74Cl2+KT/4+4TtYiqWmolSvMEGZ9ap0FoM5oyWOtRgxm/ddaESGSMqs92KBFlxnkRq31yFSDB9tkjoyr9fTOh/wEzM9BoeVK/F7mA1ICQrbm+0P2c9vYundFVqIueZYHfb9cpsvxqLngXpCToKcYZyBN6o/0v0obnH/rsm5ZT5cWFhK4YBd+czv/+DFI3IVe6EBBE/vxzGtIKRnyZqBfweD9vUd85zNQ== iPhone"
    ];
  };
  users.users.narinari = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaTFqajQTj2lgwi850i2SxGhbRMksEB3JGG9T0xlADzf//2P7pZ2SqwOA1Xj5Vi4JvcI9PK+iB4hGe+9YFx0N6DohRtWLcG8zX4pu93muEO+ZcXJ839NcFeut71PGacKIhXiw3FH7/sTyN+Jxt1msrEm1IhpqiLP4BaAUf/CvqO8vW9Qxi9vq0H27BZWxerTWE5YvvW/ftK2aCFRprnX1cfsDfitDGVqD+09i/Kr/miqOuPzH7G6Y6O6paiSZIixKSj8kl250ka0nBSSPEKTBlQEV3iybcDusqZiWz4zwwhZe+g0KxyO1GvT8O8sFzO91u+nLQM3cWbc/BbmUhu3F1w92oVicfHNAiZc1JN73nq3QOyVwBhsX3L4jBQfelEsg8MJTwTvZBtUjx+/d/njDVGSKcYyh6Y5d12socPv5D9YBuCQi3nY6oyIA5QdyloUK73FAmII1D3s74Cl2+KT/4+4TtYiqWmolSvMEGZ9ap0FoM5oyWOtRgxm/ddaESGSMqs92KBFlxnkRq31yFSDB9tkjoyr9fTOh/wEzM9BoeVK/F7mA1ICQrbm+0P2c9vYundFVqIueZYHfb9cpsvxqLngXpCToKcYZyBN6o/0v0obnH/rsm5ZT5cWFhK4YBd+czv/+DFI3IVe6EBBE/vxzGtIKRnyZqBfweD9vUd85zNQ== iPhone"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    curl
    emacs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
