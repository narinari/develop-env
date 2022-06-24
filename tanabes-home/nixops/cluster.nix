let
  pkgs = import <nixpkgs> { };
  adminUser = import ./admin-user.nix;
  vpnConfiguration = import ./vpn-configuration.nix;

  # Helper to create a machine with the wireguard configuration and the hardware
  # configuration for the specified raspberry model.
  machine = raspberry-model: name:
    ({ config, options, pkgs, ... }:
      let
        vpnClientConfiguration = vpnConfiguration.clients."${name}";
        # wireguard = import ./wireguard-client.nix {
        #   inherit vpnClientConfiguration;
        #   vpnServerConfiguration = vpnConfiguration.server;
        # };
      in
        {
          imports = [ (./. + "/hardware/rpi${raspberry-model}.nix") ];
          # deployment.targetHost = vpnClientConfiguration.ip;
          deployment.targetHost = "${name}.local";
          # List packages installed in system profile. To search, run:
          # $ nix search wget
          environment = {
            systemPackages = with pkgs; [ vim ];
            defaultPackages = options.environment.defaultPackages.default ++ (with pkgs; [ curl emacs git ]);
          };

          networking.firewall.allowedTCPPorts =
            config.services.openssh.ports ++
            [
              config.services.prometheus.port
              config.services.prometheus.exporters.node.port
              9002
              111 2049 20048 # nfs
            ];
          networking.firewall.allowedUDPPorts = [
            111 2049 20048 # nfs
          ];
        } # // wireguard
    );
in {
  network.description = "A Raspberry Pi (4) cluster.";

  # define the machines in the network
  friday = args@{ config, options, pkgs, ... }:
    (machine "4" "friday") args // {
      deployment.targetHost = "friday.local";
      deployment.keys.epgstation-db-password = {
        text = "epgstation";
        user = "epgstation";
        group = "wheel";
        permissions = "0664";
      };
      services.epgstation = {
        enable = true;
        database.passwordFile = "/run/keys/epgstation-db-password";
        openFirewall = true;
        usePreconfiguredStreaming = false;
        settings = {
          encode = import ./epgstation/encode.nix;
          stream = import ./epgstation/streaming.nix;
          mirakurunPath = "http://silk.local:40772";
        };
      };
      services.mirakurun.enable = false;
      services.prometheus = {
        enable = true;
        port = 9001;
        scrapeConfigs = [
          {
            job_name = "local exporter";
            static_configs = [{
              targets = map(name: "${name}.local:${toString config.services.prometheus.exporters.node.port}")(builtins.attrNames vpnConfiguration.clients);
            }];
          }
        ];
      };
    };
  jarvis = args@{ config, options, pkgs, ... }:
    (machine "4" "jarvis") args // {
      fileSystems."/mnt/data/xxx" =
        { device = "/dev/disk/by-label/XDATA";
          fsType = "ext4";
        };
      fileSystems."/mnt/data/tanabe-video" =
        { device = "/dev/disk/by-label/tanabe-video";
          fsType = "ext4";
        };
      fileSystems."/export/xxx" = {
        device = "/mnt/data/xxx";
        options = [ "bind" ];
      };

      services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
      networking.firewall.allowedTCPPorts = [
        5357 # wsdd
      ];
      networking.firewall.allowedUDPPorts = [
        3702 # wsdd
      ];
      services.samba = {
        enable = true;
        openFirewall = true;
        extraConfig = ''
          workgroup = WORKGROUP
          server string = tanabes-data
          netbios name = tanabes-data
          security = user
          #use sendfile = yes
          #max protocol = smb2
          # note: localhost is the ipv6 localhost ::1
          # hosts allow = 192.168.100. 127.0.0.1 localhost
          # hosts deny = 0.0.0.0/0
          interfaces = eth0 lo
          bind interfaces only = true
          guest account = nobody
          map to guest = bad user

          dos charset = CP932
          unix charset = UTF-8
          display charset = UTF-8
        '';
        shares = {
          tanabe-media = {
            path = "/mnt/data/tanabe-video";
            browseable = "yes";
            available = "yes";
            public = "yes";
            writable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "narinari";
            "force group" = "users";
          };
          xxx = {
            path = "/mnt/data/xxx";
            browseable = "no";
            available = "yes";
            writable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "narinari";
            "force group" = "users";
            "valid users" = "narinari";
          };
        };
      };

      # services.nfs.server = {
      #   enable = true;
      #   exports =
      #     ''
      #       /export     192.168.100.0/24(rw,sync,no_subtree_check,crossmnt,fsid=0) 2409:10:ae00::/64(rw,sync,no_subtree_check,crossmnt,fsid=0)
      #       /export/xxx 192.168.100.0/24(rw,sync,no_root_squash,no_subtree_check,nohide) 2409:10:ae00::/64(rw,sync,no_root_squash,no_subtree_check,nohide)
      #     '';
      #   createMountPoints = true;
      # };
    };

  # Default configuration applicable to all machines
  defaults = {
    # Setup Gnome display manager
    # services.xserver.enable = true;
    # services.xserver.layout = "us";
    # services.xserver.xkbVariant = "intl";
    # services.xserver.desktopManager.gnome3.enable = true;
    # services.xserver.displayManager.lightdm.enable = true;
    # services.xserver.videoDrivers = [ "fbdev" ];

    # Enable captive-browser
    # programs.captive-browser.enable = true;
    # programs.captive-browser.interface = "wlan0";

    # Required for the Wireless firmware
    hardware.enableRedistributableFirmware = true;

    # Networking configuration
    networking = {
      # hostName = "friday"; # Define your hostname.
      # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # The global useDHCP flag is deprecated, therefore explicitly set to false here.
      # Per-interface useDHCP will be mandatory in the future, so this generated config
      # replicates the default behaviour.
      useDHCP = false;
      interfaces.eth0.useDHCP = true;
      interfaces.wlan0.useDHCP = true;
      # networkmanager.enable = true;
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

    users = {
      # defaultUserShell = pkgs.zsh;
      users = {
      }  // adminUser;
    };

    security.sudo.wheelNeedsPassword = false;

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
      promptInit = ""; # otherwise it'll override the grml prompt
    };

    # Enable openssh and add the ssh key to the root user
    services.openssh.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };

    # nix = {
    #   autoOptimiseStore = true;
    #   gc = {
    #     automatic = true;
    #     dates = "weekly";
    #     options = "--delete-older-than 30d";
    #   };
    #   # Free up to 1GiB whenever there is less than 100MiB left.
    #   extraOptions = ''
    #     min-free = ${toString (100 * 1024 * 1024)}
    #     max-free = ${toString (1024 * 1024 * 1024)}
    #   '';
    # };

    # # Define that we need to build for ARM
    # nixpkgs.localSystem = {
    #   system = "aarch64-linux";
    #   config = "aarch64-unknown-linux-gnu";
    # };
    # nixpkgs.config = {
    #   allowUnfree = true;
    # };
    # system.stateVersion = "21.11";
  };
}
