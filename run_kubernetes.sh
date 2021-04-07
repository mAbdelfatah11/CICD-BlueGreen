#!/usr/bin/env bash

# This tags and uploads an image to Docker Hub

# Step 1:
# This is your Docker ID/path
dockerpath=proj4mlmicroservice/proj5-capstone

# Step 2
# Run the Docker Hub container with kubernetes
docker login
kubectl run proj5-capstone\
    --image=$dockerpath\
    --port=80 --labels app=proj5-capstone

# Step 3:
# List kubernetes pods and services
kubectl get pods
kubectl get svc

echo "Sleeping for 10 seconds while waiting for pod to come up."
sleep 10

# Step 5:
# Forward the container port to a host
kubectl expose deployment proj5-capstone --type=LoadBalancer --port=8080 --target-port=80

