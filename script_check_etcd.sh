s#!/bin/bash

# This script checks the etcd leader and the size of the etcd database in an OpenShift cluster.

# Ensure user is logged in
if ! oc whoami &> /dev/null; then
    echo "You must be logged into the cluster."
    exit 1
fi

# Get the list of etcd pods
etcd_pods=$(oc get pods -n openshift-etcd -l k8s-app=etcd -o jsonpath='{.items[*].metadata.name}')

leader_pod=""
db_size=""

# Iterate over the etcd pods to find the leader and get db size
for pod in $etcd_pods; do
    leader_check=$(oc exec $pod -n openshift-etcd -- etcdctl member list | grep "isLeader=true")
    if [[ ! -z "$leader_check" ]]; then
        leader_pod=$pod
    fi

    # Here, you can get the database size for each member or just for the leader. For simplicity, let's get it just for the leader
    if [[ ! -z "$leader_pod" && -z "$db_size" ]]; then
        db_size=$(oc exec $pod -n openshift-etcd -- du -sh /var/lib/etcd/member/snap/db | cut -f1)
    fi
done

if [[ ! -z "$leader_pod" ]]; then
    echo "etcd leader: $leader_pod"
else
    echo "Could not determine etcd leader."
fi

if [[ ! -z "$db_size" ]]; then
    echo "etcd database size: $db_size"
else
    echo "Could not determine etcd database size."
fi
