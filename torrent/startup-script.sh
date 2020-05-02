#!/bin/sh

docker pull google/cloud-sdk
GCLOUD_CMD="docker run -it --rm google/cloud-sdk"
DNS_ZONE_NAME=$($GCLOUD_CMD compute instances describe test --zone ${ZONE:-asia-northeast1-a} --format="value(metadata.dnsZoneName)")
ZONE=$($GCLOUD_CMD dns record-sets list --zone ${DNS_ZONE_NAME} --limit 1 --format "value(name)")

INITIALIZED_FLAG=".startup_script_initialized"

main()
{
  tell_my_private_ip_address_to_dns

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

tell_my_private_ip_address_to_dns()
{
  # Get the hostname of the instance
  HOSTNAME=$(hostname)

  # Get the ip address which is used last time
  LAST_PRIVATE_ADDRESS=$(host "${HOSTNAME}.${ZONE}" | sed -rn 's@^.* has address @@p')

  # Get the current local ip address
  PRIVATE_ADDRESS=$(hostname -i)

  # Update Cloud DNS
  TEMP=$(mktemp -u)
  $GCLOUD_CMD dns record-sets transaction start -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}"

  if test "$LAST_PRIVATE_ADDRESS" != ""
  then
    $GCLOUD_CMD dns record-sets transaction remove -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}" \
      --name "${HOSTNAME}.${ZONE}" --ttl 300 --type A "$LAST_PRIVATE_ADDRESS"
  fi
  $GCLOUD_CMD dns record-sets transaction add -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}" \
    --name "${HOSTNAME}.${ZONE}" --ttl 300 --type A "$PRIVATE_ADDRESS"
  $GCLOUD_CMD dns record-sets transaction execute -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}"
}

main
