#!/bin/bash
# note: must be authenticated via gcloud before running
# arguments:
# cluster-create-wrapper.sh cluster_NAME attendee_count
CLUSTER_PREFIX=$1
NUM_OF_CLUSTERS=$2
PROJECT=perform-vegas-hd-2020
ZONE=us-central1-a
REGION=us-central1
GKE_VERSION="1.13.11-gke.14"
echo "Configuring gcloud auth for Project=${PROJECT} and Zone=${ZONE}"
gcloud --quiet config set project $PROJECT
gcloud --quiet config set compute/zone $ZONE
echo ""
echo "will create ${NUM_OF_CLUSTERS} clusters with the prefix ${CLUSTER_PREFIX}"
for ((i=1;i<=NUM_OF_CLUSTERS;i++)); do
    # checks for existence of cluster, if it does not exist it will be created
    CLUSTER_NAME="${CLUSTER_PREFIX}${i}"
    echo "Checking for existence of cluster ${CLUSTER_NAME}"
    CLUSTER_STATUS=$(gcloud container clusters list --format="value(status)" --filter="name=${CLUSTER_NAME}")
    if [ -n "${CLUSTER_STATUS}" ]
    then
        echo "Cluster ${CLUSTER_NAME} exists with status ${CLUSTER_STATUS}, will delete"
        gcloud --quiet container clusters delete --async ${CLUSTER_NAME}
    else
        echo "Cluster ${CLUSTER_NAME} does not exist and will not be deleted"
    fi
done
