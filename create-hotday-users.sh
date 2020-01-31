#!/bin/bash
CLUSTER_PREFIX=$1
file="hotday_users.csv"
i=1
while IFS=, read -r f1 f2 f3 f4 f5 f6 f7 f8
        do
        # cut no longer necessary as parsing was done in excel for HOT day attendee card printing
        # username=$(echo $f3| cut -d'@' -f 1)
        username=$f7
        PASS=$f8
        echo "Creating user: $username"
        useradd -m -p $(openssl passwd -1 $PASS) -G docker $username
        cp /tmp/${CLUSTER_PREFIX}${i}-kubeconfig /home/${username}/.kube/config
        i=$((i+1))
done <"$file"
