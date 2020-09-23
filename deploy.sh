#!/usr/bin/env bash
# set -x
# Load the project variables into the current shell
source ./project.vars
PROJ_PATH=$(pwd)

# Check the arguments
if [[ ${#} -lt 1 ]]; then
    echo "Please define minimum one argument as the ENVIRONMENT name (e.g dev)!"
    echo "Initialization aborted."
    exit 1
fi

# Check the environment (dev,...,prod)
ENV=$1
ENV_PATH="${PROJ_PATH}/environments/${ENV}"

# Automatically execute the init.sh script, if the ARG 'init' specified.
if [[ $2 == 'init' ]]; then
  echo "Executing the init.sh script: ./init.sh ${ENV}"
  bash ./init.sh ${ENV}
  echo "If the default variables are required to be changed, you can update them and redeploy the modules."
fi

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


# Define terraform variables
export TF_VAR_region=${AWS_REGION}
export TF_VAR_project=${PROJECT}

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

# Check the secret variables file
SEC_FILE="${ENV_PATH}/.secrets/secrets.tfvars"
SEC_ARG=" -var-file=${SEC_FILE}"

if [[ ! -e ${SEC_FILE} ]]; then
    echo "The secrets.tfvar file is not found in the env secret directory ${ENV_PATH}"
    echo "Secret parameters such as DB user and pass are required for the deployment."
    echo "Please provide the required variables in ${SEC_FILE}"
    echo "The script is now aborted!"
    exit 1
fi

# Terraform init
echo "Executing: terraform init ${BACKEND_CONFIG_ARG}"
terraform init -reconfigure ${BACKEND_CONFIG_ARG}

terraform workspace select default
# Different backends exist, so no additional workspace needed.
# terraform workspace list | grep $ENV
# if [[ "${?}" -eq 0 ]]
# then
#     terraform workspace select $ENV
# else
#     terraform workspace new $ENV
# fi


if [[ $2 == 'tf' ]]; then
  echo "terraform ${@:3} ${VAR_ARG} ${SEC_ARG}"
  terraform ${@:3} ${VAR_ARG} ${SEC_ARG}
  exit 0
fi

# Destroy if the arg was defined
if [[ $2 == 'destroy' ]]; then
    echo "The script was executed with DESTROY flag!"
    read -p "Do you really want to destroy all resources of ${ENV} environment? [Y/y]" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
    echo "Executing: terraform destroy ${VAR_ARG} ${SEC_ARG}"
    terraform destroy ${VAR_ARG}
    bash ./init.sh ${ENV} destroy
    exit 0
fi

# Run the initiate deploy if specified
if [[ $2 == 'init' ]]; then
  echo "Performing initiate deploy..."

  # Define init specific variables
  INIT_ARG=' -var=wp_init=true -var=desired_capacity=1'

  echo "Executing: terraform apply -target=module.network ${VAR_ARG} ${SEC_ARG} ${INIT_ARG}"
  terraform apply -target=module.network  ${VAR_ARG} ${SEC_ARG} ${INIT_ARG}

  echo "Executing: terraform apply ${VAR_ARG} ${SEC_ARG} ${INIT_ARG}"
  terraform apply ${VAR_ARG} ${SEC_ARG} ${INIT_ARG}

fi

# Terraform apply
echo "Executing: terraform apply ${VAR_ARG} ${SEC_ARG}"
terraform apply ${VAR_ARG} ${SEC_ARG}

# END OF SCRIPT
