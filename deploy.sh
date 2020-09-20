#!/usr/bin/env bash

# Load the project variables into the current shell
source ./project.vars
PROJ_PATH=$(pwd)

# Check the arguments
if [[ ${#} -ne 1 ]]; then
    echo "Please define a single argument as the ENVIRONMENT (e.g dev)!"
    echo "Initialization aborted."
    exit 1
fi

# Check the environment (dev,...,prod)
ENV=$1
ENV_PATH="${PROJ_PATH}/environments/${ENV}"

if [[ ! -d ${ENV_PATH} ]]; then
    echo "The environment '${ENV}' does NOT exist under 'environments' directory."
    echo "Please first Initialize it by the init.sh script, then deploy the environment ${ENV}"
    echo "The script is now aborted!"
    exit 1
fi

# Check the backend file
BACKEND_CONFIG_FILE="${ENV_PATH}/backend.config"
BACKEND_CONFIG_ARG="-backend-config=${BACKEND_CONFIG_FILE}"

if [[ ! -e ${BACKEND_CONFIG_FILE} ]]; then
    echo "The backend.config file is not found in the env directory ${ENV_PATH}"
    echo "Please first Initialize the environment by the init.sh script, then try again."
    echo "The script is now aborted!"
    exit 1
fi

# Check the variables file
VAR_FILE="${ENV_PATH}/variables.tfvars"
VAR_ARG="-var-file=${VAR_FILE}"

if [[ ! -e ${VAR_FILE} ]]; then
    echo "The variables.tfvar file is not found in the env directory ${ENV_PATH}"
    echo "Please first Initialize the environment by the init.sh script, then try again."
    echo "The script is now aborted!"
    exit 1
fi

# Define the TF variable public IP address (var.my_ip)
 export TF_VAR_my_ip="$(curl checkip.amazonaws.com)/32"

# Define the TF variable ssh_pub_key
PUB_KEY_FILE="${ENV_PATH}/.secrets/ssh-key.pub"
if [[ -e ${PUB_KEY_FILE} ]]; then
  export TF_VAR_ssh_pub_key=$(cat ${PUB_KEY_FILE})
else
  export TF_VAR_ssh_pub_key="Public Key not found."
  echo "Public Key NOT found in the secret directory! Please execute the init script first, and then redeploy; otherwise ssh access to the instances are denied!"
fi

# Terraform init
echo "Executing: terraform init ${BACKEND_CONFIG_ARG}"
terraform init ${BACKEND_CONFIG_ARG}

# Terraform apply
echo "Executing: terraform apply ${VAR_ARG}"
terraform apply ${VAR_ARG}
