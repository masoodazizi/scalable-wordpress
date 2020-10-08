# Scalable WordPress Application with AWS

This project will provision all required resources in AWS environment and adjust all setup and configuration via Terraform and shell scripting to provide a highly-available and fault-tolerance WordPress application ready to use.

## Getting Started.

### Prerequisits

#### AWS Account
All the procedures and steps are automated via IaC and scripting. So the only requirement is an AWS profile with sufficient permission for all required resouces. If you are not familiar with AWS policies and permissions, you can temporarily grant the user Administrator Access or Power User permissions.

Therefore, when you have configured your AWS profile in your terminal via the Access Key and the Secret Key, you are ready to execute the deployment.

You can check the user that you have defined in the AWS profile configuration with this command (replace AWS_PROFILE with the name of your profile):

```shell
aws iam get-user --profile AWS_PROFILE
```
#### Operating System
This project was tested on MacOS Catalina and theoretically should work in all *nix environments. 

#### Interpretor
The scripts are written with Bash command language and require Bash intrepretor to execute the job, as it is defined in the beginnig of the scriot files that by which program the script should be run.

#### IaC Language
The skeleton of the project is Terraform. All the resources and automations were implemented by Terraform as the IaC. The project was tested with Terraform version `0.13.3` as it is defined in the [.terraform-version](.terraform-version) file. Some new features of TF 0.13 are applied in the code, so it would not work with the versions below 0.13 on the fly. Some adjusment is needed in the code to be able to run it with TF 0.12. However, the syntax is not compatible with the Terraform versions below 0.12.

### Parameters

Different variables can be defined to customize the environment. There are some mandatory parameters that you must define them. These variables are stored in the file [project.vars](project.vars). By specifying this variables, you can simply deploy the system with all other default variables. If you need to custmoize other configuration, you need to first initialize the system separately and then deploy the resources.

#### Mandatory Parameters
Currently the following paramteres are mandatory that you can find them in [project.vars](project.vars):
  - AWS_PROFILE: The name of the AWS profile chosen during setup. If it was not selected with `aws configure`, then the profile name is `default`
  - AWS_REGION: The region that your resources will be provisioned in. The default is `eu-central-1` which is Frankfurt. The list of all regions and their code can be found in [AWS documentations](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints)
  - PROJECT: the name of your project. It is used mostly in the naming of the resources.

#### Optional Parameters

## Development Status

This repository is under development. The tasks, features and fixes are defined in the [Projects Section](https://github.com/masoodazizi/scalable-wordpress/projects/1).

The Documentation is in the *highest priority* and will be completed soon.

If there is any problem or request, please create an issue.
