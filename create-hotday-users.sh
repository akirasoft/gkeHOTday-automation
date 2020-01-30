#!/bin/bash
CLUSTER_PREFIX=$1
file="test.csv"
i=1
while IFS=, read -r f1 f2 f3 f4 f5
        do
        username=$(echo $f2| cut -d'@' -f 1)
        PASS=$f3
        echo "Creating user: $username"
        useradd -p $(openssl passwd -1 $PASS) -G docker $username
        cp /tmp/${CLUSTER_PREFIX}${i}-kubeconfig /home/${username}/.kube/config
        i=$((i+1))
done <"$file"



