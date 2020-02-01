#!/bin/bash
CLUSTER_PREFIX=$1
file="hotday_users.csv"
while IFS=, read -r f1 f2 f3 f4 f5 f6 f7 f8
        do
        # cut no longer necessary as parsing was done in excel for HOT day attendee card printing
        # username=$(echo $f3| cut -d'@' -f 1)
        username=$f7
        echo "Creating user: $username"
        userdel -r $username
done <"$file"
