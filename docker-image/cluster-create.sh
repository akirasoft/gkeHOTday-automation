#!/bin/bash

# export PROJECT=perform-vegas-hd-2020
# export ZONE=us-central1-a
# export REGION=us-central1
# export GKE_VERSION="1.13.11-gke.14"
PROJECT=$1
CLUSTER_NAME=$2
ZONE=$3
REGION=$4
GKE_VERSION=$5

echo "Provisioning cluster"
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud beta container --project $PROJECT clusters create $CLUSTER_NAME --zone $ZONE --no-enable-basic-auth --cluster-version $GKE_VERSION --machine-type "n1-standard-8" --image-type "UBUNTU" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --enable-ip-alias --network "projects/$PROJECT/global/networks/default" --subnetwork "projects/$PROJECT/regions/$REGION/subnetworks/default" --default-max-pods-per-node "64" --addons HorizontalPodAutoscaling,HttpLoadBalancing --no-enable-autoupgrade

echo "Cluster provisioning done"

echo "get the credentials to the cluster"
gcloud container clusters get-credentials $CLUSTER_NAME \
            --zone $ZONE \
            --project $PROJECT

