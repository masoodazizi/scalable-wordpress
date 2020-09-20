# SECRETS

This directory should be empty and no secrets should be pushed to the remote repository. This path is automatically ignored by git and only this file was pushed.

This directory should contain:

* secrets.tfvars
* ssh-key
* ssh-key.pub
* any other required secrets

## secrets.tfvars

This file should keep secret variables such as passwords, for example:

```
master_username = "db_username"
master_password = "db_password"
```

## ssh-key

The key pair is generated during the Initialization with init.sh script. The public key is fetched to be used for the instances. The private key can be used by the user to login to the EC2 instances.
