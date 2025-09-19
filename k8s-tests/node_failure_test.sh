#!/bin/bash

# 1. Find a node running an application pod in the 'tabajarafy' namespace, but that does NOT have the cluster-autoscaler pod in kube-system
APP_POD=$(kubectl get pods -n tabajarafy -o jsonpath='{.items[0].metadata.name}')
NODE=""
for n in $(kubectl get pod $APP_POD -n tabajarafy -o jsonpath='{.spec.nodeName}'); do
  # Check if this node is running the cluster-autoscaler pod in kube-system
  AUTOSCALER_POD=$(kubectl get pods -n kube-system -o wide | grep cluster-autoscaler-aws-cluster-autoscaler | awk '{print $7}')
  if [[ "$AUTOSCALER_POD" != "$n" ]]; then
    NODE="$n"
    break
  fi
done
if [ -z "$NODE" ]; then
  echo "No suitable node found (all nodes running cluster-autoscaler pod)."
  exit 1
fi
echo "Selected node running an application pod (not running cluster-autoscaler): $NODE"

# 2. Get the corresponding EC2 instance ID
INSTANCE_ID=$(kubectl get node $NODE -o jsonpath='{.spec.providerID}' | cut -d'/' -f5)
echo "Instance ID: $INSTANCE_ID"

# 3. Get the application LoadBalancer endpoint (before killing the node)
APP_URL=$(kubectl get svc -n tabajarafy -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
echo "Application endpoint: http://$APP_URL"

# 4. Test the endpoint before killing the node
echo "Testing endpoint before node termination:"
curl -I "http://$APP_URL"

# 5. Terminate the EC2 instance (simulate node failure)
echo "Terminating the EC2 instance..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region us-east-1 | cat

# 6. Test the endpoint 10 seconds after node termination
echo "Testing endpoint 10 seconds after node termination:"
sleep 10
curl -I "http://$APP_URL"

# 7. Wait for a new node (with a different name) to join the cluster
echo "Waiting for a new node to join the cluster..."
NODES_BEFORE=$(kubectl get nodes -o name)
while true; do
  sleep 10
  NODES_AFTER=$(kubectl get nodes -o name)
  NEW_NODE=$(comm -13 <(echo "$NODES_BEFORE" | sort) <(echo "$NODES_AFTER" | sort))
  if [ -n "$NEW_NODE" ]; then
    echo "New node detected: $NEW_NODE"
    break
  fi
  echo "Waiting for node to be replaced by the ASG..."
done

# 8. Check if the application pods are running
echo "Checking application pods:"
kubectl get pods -n tabajarafy -o wide

# 9. Test the endpoint after node replacement
echo "Testing endpoint after node replacement:"
curl -I "http://$APP_URL"

echo "Node failure resilience test completed!"