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
echo "will create ${NUM_OF_CLUSTERS} clusters with the prefix ${CLUSTER_PREFIX}"
for ((i=1;i<=NUM_OF_CLUSTERS;i++)); do
    # cluster-create.sh creates the cluster
    CLUSTER_NAME="${CLUSTER_PREFIX}${i}"
    ./cluster-create.sh ${PROJECT} ${CLUSTER_NAME} ${ZONE} ${REGION} ${GKE_VERSION} 
    # get-kubeconfig creates and uploads cert to remove gcloud pre-req for k8s auth
    # creates kubeconfig file in build dir
    sleep 5
    kubectl cluster-info
    ./get-kubeconfig.sh ${CLUSTER_NAME}
done

