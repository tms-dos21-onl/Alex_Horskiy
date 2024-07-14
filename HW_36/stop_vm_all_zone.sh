#!/bin/bash

# Determine the list of zones
zones=("us-central1-a", "us-central1-b", "us-central1-c")  # My zone

# Loop to stop VM in all zone
for zone in "${zones[@]}"
do
  echo "Stopping instances in zone: $zone"
  gcloud compute instances stop $(gcloud compute instances list --format="value(name)" --filter="zone:$zone") --zone=$zone --quiet
done