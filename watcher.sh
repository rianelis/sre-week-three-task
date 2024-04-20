#!/bin/bash

# Define script variables:
# NAMESPACE - The Kubernetes namespace where the deployment is located.
# DEPLOYMENT_NAME - The name of the deployment to be monitored.
# MAX_RESTARTS - The maximum number of allowed restarts before intervention.
NAMESPACE="sre"
DEPLOYMENT_NAME="swype-app"
MAX_RESTARTS=3

# Start an infinite loop to continuously monitor pod restarts.
# This allows for ongoing checks without manual intervention.
while true; do
    # Fetch the current number of restarts for the first container in the first pod
    # matching the deployment name in the specified namespace.
    # kubectl command is used with a JSONPath expression to extract the restart count.
    CURRENT_RESTARTS=$(kubectl get pods -n ${NAMESPACE} -l app=${DEPLOYMENT_NAME} -o jsonpath="{.items[0].status.containerStatuses[0].restartCount}")

    # Output the current restart count to the console for logging and debugging.
    echo "Current restart count for $DEPLOYMENT_NAME: $CURRENT_RESTARTS"

    # Check if the current restart count exceeds the predefined maximum allowed restarts.
    if [ "$CURRENT_RESTARTS" -gt "$MAX_RESTARTS" ]; then
        # If the restart limit is exceeded, log this status and proceed to scale down the deployment.
        echo "Restart limit exceeded. Scaling down $DEPLOYMENT_NAME."
        
        # Scale the deployment down to zero replicas to stop the faulty behavior and prevent further issues.
        # This command adjusts the deployment's replica count to zero within the specified namespace.
        kubectl scale deployment $DEPLOYMENT_NAME --replicas=0 -n $NAMESPACE
        
        # Exit the loop and terminate the script as the necessary action has been taken.
        break
    else
        # If the restart count is within limits, pause the script for 60 seconds before the next check.
        # This delay helps manage resource usage and reduces the frequency of checks.
        sleep 60
    fi
done
