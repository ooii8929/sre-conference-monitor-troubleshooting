#!/bin/bash

# Initialize a variable to keep track of any errors
errors_detected=0

# Check if AWS CLI, Terraform, Helm, and kubectl are installed
if ! command -v aws &>/dev/null; then
    echo "AWS CLI is not installed. Please install it."
    errors_detected=1
fi

if ! command -v terraform &>/dev/null; then
    echo "Terraform is not installed. Please install it."
    errors_detected=1
fi

if ! command -v helm &>/dev/null; then
    echo "Helm is not installed. Please install it."
    errors_detected=1
fi

if ! command -v kubectl &>/dev/null; then
    echo "kubectl is not installed. Please install it."
    errors_detected=1
fi

# Ensure you can access AWS
aws sts get-caller-identity >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Cannot access AWS. Please check your credentials."
    errors_detected=1
fi

# Verify that you have full access to EKS
kubectl get all --all-namespaces >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "You do not have full access to EKS. Please check your permissions."
    errors_detected=1
fi

# Check if Docker is installed and running
if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install it."
    errors_detected=1
elif ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start the Docker service."
    errors_detected=1
fi

# If no errors detected, print success message
if [ $errors_detected -eq 0 ]; then
    echo "All checks passed. You can start the lab."
fi
