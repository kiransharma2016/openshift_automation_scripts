#!/bin/bash

# This script checks the status of OpenShift Cluster Operators and alerts if there are any abnormalities.

# Fetch ClusterOperators status
operators_status=$(oc get co -o jsonpath='{range .items[*]}{.metadata.name}{"\tAvailable="}{.status.conditions[?(@.type=="Available")].status}{"\tDegraded="}{.status.conditions[?(@.type=="Degraded")].status}{"\tProgressing="}{.status.conditions[?(@.type=="Progressing")].status}{"\n"}{end}')

abnormalities=""

# Parse each line of the status output to identify any abnormalities
while IFS= read -r line; do
    if ! echo "$line" | grep -q "Available=True" || echo "$line" | grep -q "Degraded=True" || echo "$line" | grep -q "Progressing=True"; then
        abnormality=$(echo "$line" | awk '{print $1}')
        abnormalities="$abnormalities$abnormality\n"
    fi
done <<< "$operators_status"

if [[ -z $abnormalities ]]; then
    echo "All ClusterOperators are in a healthy state."
else
    echo -e "ACT FYI: Abnormal ClusterOperators detected:\n$abnormalities"
fi
