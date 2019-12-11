#!/bin/bash
# note: must be authenticated via gcloud before running
# arguments:
# cluster-create-wrapper.sh cluster_NAME attendee_count
CLUSTER_NAME=$1
NUM_OF_CLUSTERS=$2
PROJECT=perform-vegas-hd-2020
ZONE=us-central1-a
REGION=us-central1
GKE_VERSION="1.13.11-gke.14"

for i in {1..${NUM_OF_CLUSTERS}}
do
    # cluster-create.sh creates the cluster 
    ./cluster-create.sh ${PROJECT} ${CLUSTER_NAME} ${ZONE} ${REGION} ${GKE_VERSION} 
    # get-kubeconfig creates and uploads cert to remove gcloud pre-req for k8s auth
    # creates kubeconfig file in build dir
    ./get-kubeconfig.sh ${CLUSTER_NAME}

done
