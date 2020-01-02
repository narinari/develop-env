#!/bin/bash

# Settings
PROJECT_NAME="sdachi-dev"
DNS_ZONE_NAME="localhost-zone"
GITHUB_REPO="narinari/develop-env"

IMAGE_FAMILY="ubuntu-1804-lts"
IMAGE_PROJECT="ubuntu-os-cloud"

# Arguments
INSTANCE_NAME="$1"

if test "$INSTANCE_NAME" = ""
then
  echo "[Error] Instance name required." 1>&2
  exit 1
fi

# Startup script
CONTENTS_ROOT="https://raw.githubusercontent.com/${GITHUB_REPO}/master"
STARTUP_SCRIPT_URL="${CONTENTS_ROOT}/remote/startup-script.sh"

# Download startup script
TEMP=$(mktemp -u)
CONTENTS_ROOT="https://raw.githubusercontent.com/${GITHUB_REPO}/master"
curl ${CONTENTS_ROOT}/remote/startup-script.sh > "${TEMP}"

# Get Service Account information
SERVICE_ACCOUNT=$(\
  gcloud iam --project "${PROJECT_NAME}" \
    service-accounts list \
    --limit 1 \
    --format "value(email)")

# Create a instance
gcloud compute --project "${PROJECT_NAME}" \
  instances create "${INSTANCE_NAME}" \
  --zone "asia-northeast1-a" \
  --machine-type "g1-small" \
  --subnet "default" \
  --maintenance-policy "MIGRATE" \
  --service-account "${SERVICE_ACCOUNT}" \
  --scopes "https://www.googleapis.com/auth/cloud-platform" \
  --min-cpu-platform "Automatic" \
  --image-family $IMAGE_FAMILY \
  --image-project $IMAGE_PROJECT \
  --boot-disk-size "10" \
  --boot-disk-type "pd-standard" \
  --boot-disk-device-name "${INSTANCE_NAME}" \
  --metadata startup-script-url="${STARTUP_SCRIPT_URL}",dnsZoneName="${DNS_ZONE_NAME}"
  
rm "${TEMP}"
