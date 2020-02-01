#!/bin/bash
# note: must be authenticated via gcloud before running
# arguments:
# cluster-create-wrapper.sh cluster_NAME attendee_count
CLUSTER_PREFIX=$1
NUM_OF_CLUSTERS=$2
PROJECT=perform-vegas-hd-2020
ZONE=us-central1-a
REGION=us-central1

echo "Configuring gcloud auth for Project=${PROJECT} and Zone=${ZONE}"
gcloud --quiet config set project $PROJECT
gcloud --quiet config set compute/zone $ZONE
echo "will empty ${NUM_OF_CLUSTERS} clusters with the prefix ${CLUSTER_PREFIX}"
echo ""
for ((i=1;i<=NUM_OF_CLUSTERS;i++)); do
    # checks for existence of cluster, if it does not exist it will be created
    CLUSTER_NAME="${CLUSTER_PREFIX}${i}"
    echo "Checking for existence of cluster ${CLUSTER_NAME}"
    CLUSTER_ZONE=$(gcloud container clusters list --format="value(zone)" --filter="name=${CLUSTER_NAME}")
    CLUSTER_STATUS=$(gcloud container clusters list --format="value(status)" --filter="name=${CLUSTER_NAME}")
    if [[ ${CLUSTER_STATUS} == "RUNNING" ]]
    then
        echo "Logging into cluster ${CLUSTER_NAME}"
        gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE}
        echo "Removing helm secrets"
        if [[ -n $(kubectl get -n kube-system secrets -o name|grep tiller) ]]; then
            kubectl get -n kube-system secrets -o name|grep tiller|xargs kubectl -n kube-system delete
        fi
        echo "Removing helm service accounts"
        if [[ -n $(kubectl get -n kube-system sa -o name|grep tiller) ]]; then
            kubectl get -n kube-system sa -o name|grep tiller|xargs kubectl -n kube-system delete
        fi
        echo "Removing helm clusterrolebindings"
        if [[ -n $(kubectl get -n kube-system clusterrolebinding -o name|grep tiller) ]]; then
            kubectl get -n kube-system clusterrolebinding -o name|grep tiller|xargs kubectl -n kube-system delete
        fi
        echo "Removing helm labeled apps"
        if [[ -n $(kubectl get all -n kube-system -l app=helm -o name) ]]; then
            kubectl get all -n kube-system -l app=helm -o name|xargs kubectl delete -n kube-system
        fi
        echo "Now deleting namespaces"
        for NAMESPACE in $(kubectl get ns --output=jsonpath={.items[*].metadata.name}); do
        if [[ ${NAMESPACE} != "kube-system" ]]; then
            if [[ ${NAMESPACE} != "kube-public" ]]; then
                if [[ ${NAMESPACE} != "default" ]]; then       
                    #do 
                     echo "Will delete $NAMESPACE in $CLUSTER_NAME"
                    kubectl delete ns/$NAMESPACE &
                echo ""
                fi
            fi
        fi
        done;
    else
        echo "Cluster ${CLUSTER_NAME} is in a non running status"
    fi
done
