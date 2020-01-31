Automation for standing up GKE clusters for 2020 HOT days

run the container as follows:
 docker run -d -t --rm --name gkeautomation mvilliger/gkehotday-automation:0.4 && docker exec -it gkeautomation /bin/sh -c "[ -e /bin/bash ] && /bin/bash || /bin/sh"

Inside container, get auth'd to gcloud:
gcloud auth login --no-launch-browser

create clusters as follows:
cd scripts
./cluster-create-wrapper.sh <class-name> <number of clusters>

Clusters will be created in the format of classname and a sequential number

a Kubeconfig for each cluster will be generated in the build folder on the container. 

If you would like each user's bastion to only be able to login to the respective cluster, copy the cluster's kubeconfig to the bastion

create-hotday-users.sh provided for creation of bastion users based on the format:

---
Session Name | Mo 1-5/ Mo 6-10/ Tue 8-12/ Tue 1-5 | SaaS Environment | SaaS Login | SaaS Password | Bastion Host | Bastion Login | Bastion Password
---

create-hotday-users.sh also expects cluster_prefix as an input and kubeconfig files to be located in /tmp named via the cluster_prefix used for GKE cluster creation.

Workflow would be:
1. start container:
    ```console
    docker run -d -t --rm --name gkeautomation mvilliger/gkehotday-automation:0.3 && docker exec -it gkeautomation /bin/sh -c "[ -e /bin/bash ] && /bin/bash || /bin/sh"
    ```
1. create clusters
    ```console
    cd /usr/gkeauto/scripts
    ./cluster-create-wrapper <hotdayname> <# of clusters>
    ```
1. scp or upload hotday_users.csv to bastion
1. wget create-hotday-users.sh from the bastion
    ```console
    wget -O create-hotday-users.sh "https://raw.githubusercontent.com/akirasoft/gkeHOTday-automation/master/create-hotday-users.sh"
    chmod +x create-hotday-users.sh
    ```
1. scp or upload ALL kubeconfig files from docker container to /tmp on bastion
1. run user create script on bastion
    ```console
    ./create-hotday-users.sh <hotdayname>
    ```

