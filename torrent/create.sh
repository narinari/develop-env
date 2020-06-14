#!/bin/sh

# Settings
PROJECT_NAME="${PROJECT_NAME:-develop-env}"
GITHUB_REPO="narinari/develop-env"
INSTANCE_NAME="torrent"

# Startup script
CONTENTS_ROOT="https://raw.githubusercontent.com/${GITHUB_REPO}/master"
STARTUP_SCRIPT_URL="${CONTENTS_ROOT}/torrent/startup-script.sh"

# Get Service Account information
SERVICE_ACCOUNT=$(\
  gcloud iam --project "${PROJECT_NAME}" \
    service-accounts list \
    --limit 1 \
    --format "value(email)")

# Create a instance
gcloud beta compute --project "${PROJECT_NAME}" \
  instances create "${INSTANCE_NAME}" \
  --zone "${ZONE:-us-west1-a}" \
  --machine-type "g1-small" \
  --subnet "default" \
  --can-ip-forward \
  --tags "torrent" \
  --maintenance-policy "MIGRATE" \
  --service-account "${SERVICE_ACCOUNT}" \
  --min-cpu-platform "Automatic" \
  --image-family "cos-stable" \
  --image-project "cos-cloud" \
  --boot-disk-size "30" \
  --boot-disk-type "pd-standard" \
  --boot-disk-device-name "${INSTANCE_NAME}" \
  --metadata startup-script-url="${STARTUP_SCRIPT_URL}"
