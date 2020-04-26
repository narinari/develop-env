#!/bin/sh

USERNAME="narinari_t"

DNS_ZONE_NAME=$(gcloud compute instances describe test --zone ${ZONE:-asia-northeast1-a} --format="value(metadata.dnsZoneName)")
ZONE=$(gcloud dns record-sets list --zone ${DNS_ZONE_NAME} --limit 1 --format "value(name)")

INITIALIZED_FLAG=".startup_script_initialized"

main()
{
  tell_my_ip_address_to_dns
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
  # Foundamental tools
  apt-get update
  apt-get install -y \
     build-essential \
     chromium-browser \
     libgconf-2-4 \
     openvpn \
     unzip \
     mosh \
     zsh \
     emacs \
     curl

  # Kryptonite CLI for key management
  curl https://krypt.co/kr | sh

  # Git
  sudo -i -u "${USERNAME}" git config --global user.name "TANABE Takashi"
  sudo -i -u "${USERNAME}" git config --global user.email "narinari@gmail.com"

  # yadm
  curl -fLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && \
  chmod a+x /usr/local/bin/yadm
}

# Update on each startup except the first time
update()
{
  apt-get update
  apt-get upgrade -y
  kr upgrade
}

tell_my_ip_address_to_dns()
{
  # Get the hostname of the instance
  HOSTNAME=$(hostname)

  # Get the ip address which is used last time
  LAST_PUBLIC_ADDRESS=$(host "public.${HOSTNAME}.${ZONE}" | sed -rn 's@^.* has address @@p')
  LAST_PRIVATE_ADDRESS=$(host "${HOSTNAME}.${ZONE}" | sed -rn 's@^.* has address @@p')

  # Get the current public ip address via Metadata API
  METADATA_SERVER="http://metadata.google.internal/computeMetadata/v1"
  QUERY="instance/network-interfaces/0/access-configs/0/external-ip"
  PUBLIC_ADDRESS=$(curl "${METADATA_SERVER}/${QUERY}" -H "Metadata-Flavor: Google")
  
  # Get the current local ip address
  PRIVATE_ADDRESS=$(hostname -i)

  # Update Cloud DNS
  TEMP=$(mktemp -u)
  gcloud dns record-sets transaction start -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}"
  if test "$LAST_PUBLIC_ADDRESS" != ""
  then
    gcloud dns record-sets transaction remove -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}" \
      --name "public.${HOSTNAME}.${ZONE}" --ttl 300 --type A "$LAST_PUBLIC_ADDRESS"
  fi
  gcloud dns record-sets transaction add -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}" \
    --name "public.${HOSTNAME}.${ZONE}" --ttl 300 --type A "$PUBLIC_ADDRESS"
  
  if test "$LAST_PRIVATE_ADDRESS" != ""
  then
    gcloud dns record-sets transaction remove -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}" \
      --name "${HOSTNAME}.${ZONE}" --ttl 300 --type A "$LAST_PRIVATE_ADDRESS"
  fi
  gcloud dns record-sets transaction add -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}" \
    --name "${HOSTNAME}.${ZONE}" --ttl 300 --type A "$PRIVATE_ADDRESS"
  gcloud dns record-sets transaction execute -z "${DNS_ZONE_NAME}" --transaction-file="${TEMP}"
}

main
