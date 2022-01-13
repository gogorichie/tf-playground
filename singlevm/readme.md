# Terraform Create A Single Azure VM Within Existing Network:

# Goal: 

Teaching the basics of how to add a resource to an existing network using the data type to refer to an existing resource. In this example we will be deploying a VM which is common in brownfield migrations.


# Resource Plan:

This Terraform plan will provision the following resources listed below:

* VM
* NIC
* Shutdown Schedule


# Deployment Instructions:
1. Install Terraform [package](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. [Fork/copy](https://docs.microsoft.com/en-us/azure/devops/repos/git/forks?view=azure-devops&tabs=visual-studio#create-the-fork) this repo rep
3. Open the project locally with VSCode or your favorite text editor
4. Log into subscription wishing to deploy too with Az Login and set the root subscription as the active subscription:
    `az account set --subscription <<subscription id>>`
5.     terraform init
   - terraform workspace new <<workspace name, eg nonprod, prod, etc.>>
   - terraform workspace select <<workspace name used in previous step>>
   - terraform plan
   - terraform apply
