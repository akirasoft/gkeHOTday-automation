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
        echo "Cluster ${CLUSTER_NAME} exists with status ${CLUSTER_STATUS}, does not need to be created"
    else
        echo "Cluster ${CLUSTER_NAME} does not exist and will be created"
        if [ $i -le 35 ]
        then
            ZONE=us-central1-b
            REGION=us-central1
            ./cluster-create.sh ${PROJECT} ${CLUSTER_NAME} ${ZONE} ${REGION} ${GKE_VERSION} ${CLUSTER_PREFIX}
        else
            ZONE=us-central1-c
            REGION=us-central1
            ./cluster-create.sh ${PROJECT} ${CLUSTER_NAME} ${ZONE} ${REGION} ${GKE_VERSION} ${CLUSTER_PREFIX}
        fi
        sleep 5
    fi
done
# need second logic block for kubeconfig generation so we don't have to wait inline for all the clusters to finish provisioning
for ((i=1;i<=NUM_OF_CLUSTERS;i++)); do
    CLUSTER_NAME="${CLUSTER_PREFIX}${i}"
    KUBECONFIGFILENAME="${CLUSTER_NAME}-kubeconfig"
    until [[ $(gcloud container clusters list --format="value(status)" --filter="name=${CLUSTER_NAME}") == "RUNNING" ]];
    do
        CLUSTER_STATUS=$(gcloud container clusters list --format="value(status)" --filter="name=${CLUSTER_NAME}")
        echo "Status for ${CLUSTER_NAME} is ${CLUSTER_STATUS}, waiting 30 seconds"
        sleep 30
    done
    if [ -f "build/${KUBECONFIGFILENAME}" ]
    then
        echo "File ${KUBECONFIGFILENAME} exists, for server $(yq r build/${KUBECONFIGFILENAME} clusters.[0].cluster.server), skipping"
    else
        CLUSTER_ZONE=$(gcloud container clusters list --format="value(zone)" --filter="name=${CLUSTER_NAME}")
        gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE}
        #kubectl config use-context gke_${PROJECT}_${ZONE}_${CLUSTER_PREFIX}${i}
        # get-kubeconfig creates and uploads cert to remove gcloud pre-req for k8s auth
        # creates kubeconfig file in build dir
        # when 4 ocntainers are ready, begin kubeconfig creation
        until [[ $(kubectl get pods -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[*].status.phase}') == "Running" ]];
        do
            echo "kube-dns for ${CLUSTER_NAME} still provisioning, waiting 30 seconds"
            sleep 15
        done
        echo "cluster ${CLUSTER_NAME} created, now enabling access"
        ./get-kubeconfig.sh ${CLUSTER_NAME} ${KUBECONFIGFILENAME}
    fi
    echo ""

done
