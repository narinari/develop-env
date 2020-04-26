#!/bin/sh

#!/bin/sh

INITIALIZED_FLAG=".startup_script_initialized"

main()
{
  if test -e $INITIALIZED_FLAG
  then
    # Startup Scripts
    update
  else
    # Only first time
    setup
    touch $INITIALIZED_FLAG
  fi
}

# Installation and settings
setup()
{
iptables -w -A INPUT -p tcp --dport 80 -j ACCEPT

if [ "$(docker container ls -a -q -f name=cloud-torrent)" ]; then
    docker start cloud-torrent
else
    user=$(curl "http://metadata.google.internal/computeMetadata/v1/project/attributes/ssh-keys" -H "Metadata-Flavor: Google" | cut -d: -f1 | tail -n1)
    while [[ ! -d "/home/$user" ]] ; do
        sleep 1
    done
    mkdir -p "/home/$user/downloads"
    cd "/home/$user"
    uid=$(id -u "$user")
    gid=$(id -g "$user")
    chown $uid:$gid downloads
    docker run --name cloud-torrent -d -p 80:3000 -u $uid:$gid -v "$PWD/downloads:/downloads" jpillora/cloud-torrent
fi
}

# Update on each startup except the first time
update()
{
:
}

main
