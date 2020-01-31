#!/bin/bash
NETWORK_NAME=$1
# creating vpc network with subnet mode of custom so as not to create subnets we will never use
gcloud compute --project=perform-vegas-hd-2020 networks create ${NETWORK_NAME} \
    --description="Network for HOT day" --subnet-mode=custom

gcloud compute --project=perform-vegas-hd-2020 firewall-rules create ${NETWORK_NAME}-allow-icmp \
    --description="Allows ICMP connections from any source to any instance on the network." \
    --direction=INGRESS \
    --priority=65534 \
    --network=${NETWORK_NAME} \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=0.0.0.0/0

gcloud compute --project=perform-vegas-hd-2020 firewall-rules create ${NETWORK_NAME}-allow-internal \
    --description="Allows connections from any source in the network IP range to any instance on the network using all protocols." \
    --direction=INGRESS \
    --priority=65534 \
    --network=${NETWORK_NAME} \
    --action=ALLOW \
    --rules=all \
    --source-ranges=10.128.0.0/9

gcloud compute --project=perform-vegas-hd-2020 firewall-rules create ${NETWORK_NAME}-allow-ssh \
    --description="Allows TCP connections from any source to any instance on the network using port 22." \
    --direction=INGRESS \
    --priority=65534 \
    --network=${NETWORK_NAME} \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0
