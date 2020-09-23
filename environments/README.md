# Environments

The different environments of the deployment stages are stored here.

AS an example, the environments can be:
 - dev
 - test
 - prod

## Create new environment

If a new environment is required, the script init.sh in the root directory can handle it. This script would also be executed by defining init argument for deploy script, i.e: `./deploy.sh env init`
