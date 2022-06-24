{
  # List the clients secrets here
  clients = {
    friday = {
      ip = "192.168.100.22"; # "2409:10:ae00:6400:e65f:1ff:fe0c:8787";
      addresses = [ ];
      privateKey = builtins.readFile ("/home/narinari/wireguard-keys/takehaya-private");
    };
    jarvis = {
      ip = "192.168.100.24";
      addresses = [];
      privateKey = "";
    };
  };

  # Configuration of the VPN server
  server = {
    publicKey = builtins.readFile (./. + "server-publickey");
    allowedIPs = [ "" ];
    ip = "";
    port = 51820;
  };
}
