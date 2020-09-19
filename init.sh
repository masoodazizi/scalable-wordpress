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

# The relative path of the ssh key for init module
KEY_NAME='ssh-key'
KEY_PATH="${PROJ_PATH}/environments/${ENV}/.secrets/${KEY_NAME}"

# Check if ssh_key is not already existed
if [[ ! -e ${KEY_PATH} ]]; then
    CREATE_KEY=1
    echo "No SSH key found. The script generates a new key pair in the path '${KEY_PATH}'"
else
    CREATE_KEY=0
fi

### To force generating new key, uncomment this variable:
# CREATE_KEY=1

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
    -var="env=${ENV}" -var="project_name=${PROJECT}" -var="ssh_key_path=${KEY_PATH}" -var="create_sshkey=${CREATE_KEY}"
