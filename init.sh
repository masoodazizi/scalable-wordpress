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

# Define the environment (dev,...,prod)
ENV=$1
if [[ ! -d "environments/${ENV}" ]]; then
    echo "The environment '${ENV}' does NOT exist under 'environments' directory. Please check the spelling!"
    echo "The following environments are available:"
    ls environments/
    exit 1
fi

# The path of the ssh key for init module
KEY_NAME='ssh-key'
KEY_DIR="${PROJ_PATH}/environments/${ENV}/.secrets"
KEY_FILE="${KEY_DIR}/${KEY_NAME}"

# Make sure the path is existing
mkdir -p ${KEY_DIR}

# Initialize Terraform on the init module
cd ${PROJ_PATH}/init
terraform init

# Select/create the workspace
terraform workspace list | grep $ENV
if [[ "${?}" -eq 0 ]]
then
    terraform workspace select $ENV
else
    terraform workspace new $ENV
fi

# Deploy the init resources
terraform apply -var="aws_profile=${AWS_PROFILE}" -var="aws_region=${AWS_REGION}" \
    -var="env=${ENV}" -var="project_name=${PROJECT}" -var="ssh_key_file=${KEY_FILE}"
