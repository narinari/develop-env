let
  vpnConfiguration = import ./vpn-configuration.nix;
  adminUser = import ./admin-user.nix;
  gcpCredential = builtins.fromJSON (builtins.readFile (./. + "/sdachi-dev-86760d9260b2.json"));
in {
  network.description = "The Wireguard server.";

  sdachi-vpn-server = { pkgs, ... }: {
    imports =
      [ <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix> ];

    deployment.targetEnv = "gce";
    deployment.gce = {
        # credentials
        project = "sdachi-dev";
        serviceAccount = gcpCredential.client_email;
        accessKey = gcpCredential.private_key;

        sourceUri = "gs://nixos-cloud-images/nixos-image-20.19.3531.3858fbc08e6-x86_64-linux.raw.tar.gz";

        # instance properties
        region = "asia-northeast1-b";
        instanceType = "e2-medium";
        tags = ["vpn"];
        scheduling.automaticRestart = true;
        scheduling.onHostMaintenance = "MIGRATE";
        rootDiskSize = 200; # 200GB

      } ;
    # deployment.targetHost = vpnConfiguration.server.ip;

    # Configure the NAT/Firewall
    networking.nat.enable = true;
    networking.nat.externalInterface = "eth0";
    networking.nat.internalInterfaces = [ "sdachi-vpn" ];
    networking.firewall = {
      allowedTCPPorts = [ 25 53 ];
      allowedUDPPorts = [ 25 53 51820 ];
    };

    # Wireguard server
    networking.wg-quick.interfaces.sdachi-vpn = {
      address = [ "10.0.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/home/narinari/wireguard-keys/server-private";

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i sdachi-vpn -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i sdachi-vpn -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
      '';

      peers = [
        { # Raspberry Pi 4 friday
          publicKey = "Scj6DuWKk69aq+P/ZE795PTDYFYqL5kEVDM4D3eOigU=";
          allowedIPs = [ "10.0.0.3/32" ];
        }
      ];
    };

    networking.hosts = { "10.0.0.3" = [ "hydra.hugo" ]; };

    # DNS Server
    services.dnsmasq = {
      enable = true;
      servers = [ "8.8.8.8" "1.1.1.1" ];
      extraConfig = ''
        interface=sdachi-vpn
      '';
    };

    # Install packages
    environment.systemPackages = with pkgs; [ git vim emacs curl];

    security.sudo.wheelNeedsPassword = false;

    users = {
      # defaultUserShell = pkgs.zsh;
      users = {
      }  // adminUser;
    };
  };
}
