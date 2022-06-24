{
  root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaTFqajQTj2lgwi850i2SxGhbRMksEB3JGG9T0xlADzf//2P7pZ2SqwOA1Xj5Vi4JvcI9PK+iB4hGe+9YFx0N6DohRtWLcG8zX4pu93muEO+ZcXJ839NcFeut71PGacKIhXiw3FH7/sTyN+Jxt1msrEm1IhpqiLP4BaAUf/CvqO8vW9Qxi9vq0H27BZWxerTWE5YvvW/ftK2aCFRprnX1cfsDfitDGVqD+09i/Kr/miqOuPzH7G6Y6O6paiSZIixKSj8kl250ka0nBSSPEKTBlQEV3iybcDusqZiWz4zwwhZe+g0KxyO1GvT8O8sFzO91u+nLQM3cWbc/BbmUhu3F1w92oVicfHNAiZc1JN73nq3QOyVwBhsX3L4jBQfelEsg8MJTwTvZBtUjx+/d/njDVGSKcYyh6Y5d12socPv5D9YBuCQi3nY6oyIA5QdyloUK73FAmII1D3s74Cl2+KT/4+4TtYiqWmolSvMEGZ9ap0FoM5oyWOtRgxm/ddaESGSMqs92KBFlxnkRq31yFSDB9tkjoyr9fTOh/wEzM9BoeVK/F7mA1ICQrbm+0P2c9vYundFVqIueZYHfb9cpsvxqLngXpCToKcYZyBN6o/0v0obnH/rsm5ZT5cWFhK4YBd+czv/+DFI3IVe6EBBE/vxzGtIKRnyZqBfweD9vUd85zNQ== iPhone"
    ];
  };
  narinari = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaTFqajQTj2lgwi850i2SxGhbRMksEB3JGG9T0xlADzf//2P7pZ2SqwOA1Xj5Vi4JvcI9PK+iB4hGe+9YFx0N6DohRtWLcG8zX4pu93muEO+ZcXJ839NcFeut71PGacKIhXiw3FH7/sTyN+Jxt1msrEm1IhpqiLP4BaAUf/CvqO8vW9Qxi9vq0H27BZWxerTWE5YvvW/ftK2aCFRprnX1cfsDfitDGVqD+09i/Kr/miqOuPzH7G6Y6O6paiSZIixKSj8kl250ka0nBSSPEKTBlQEV3iybcDusqZiWz4zwwhZe+g0KxyO1GvT8O8sFzO91u+nLQM3cWbc/BbmUhu3F1w92oVicfHNAiZc1JN73nq3QOyVwBhsX3L4jBQfelEsg8MJTwTvZBtUjx+/d/njDVGSKcYyh6Y5d12socPv5D9YBuCQi3nY6oyIA5QdyloUK73FAmII1D3s74Cl2+KT/4+4TtYiqWmolSvMEGZ9ap0FoM5oyWOtRgxm/ddaESGSMqs92KBFlxnkRq31yFSDB9tkjoyr9fTOh/wEzM9BoeVK/F7mA1ICQrbm+0P2c9vYundFVqIueZYHfb9cpsvxqLngXpCToKcYZyBN6o/0v0obnH/rsm5ZT5cWFhK4YBd+czv/+DFI3IVe6EBBE/vxzGtIKRnyZqBfweD9vUd85zNQ== iPhone"
    ];
  };
}
