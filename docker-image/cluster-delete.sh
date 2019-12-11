#!/bin/bash
# note: must be authenticated via gcloud before running
# arguments:
# cluster-create-wrapper.sh cluster_NAME attendee_count
CLUSTER_PREFIX=$1
NUM_OF_CLUSTERS=$2
PROJECT=perform-vegas-hd-2020
ZONE=us-central1-a
REGION=us-central1
echo "will delete ${NUM_OF_CLUSTERS} clusters with the prefix ${CLUSTER_PREFIX}"
gcloud --quiet config set project $PROJECT
gcloud --quiet config set compute/zone $ZONE
for ((i=1;i<=NUM_OF_CLUSTERS;i++)); do
    # cluster-create.sh creates the cluster
    CLUSTER_NAME="${CLUSTER_PREFIX}${i}"
    gcloud --quiet config set container/cluster $CLUSTER_NAME
    gcloud --quiet container clusters delete $CLUSTER_NAME --async 
done

