# Exercise 6 The Terraform Configuration Language II
This exercise combines a series of Hashicorp Terraform tutorials that cover some of the configuration language features we have learned so far.
## 1. Query Data Sources (20-30min)
- This tutorial shows how to set up a Terraform configuration to query data sources for AZ, AMIs, and other variables that make a module generalizable.
- https://learn.hashicorp.com/tutorials/terraform/data-sources
- Ensure you follow the instructions for `Terraform Community Edition`.
- You will need to change the required_version of Terraform in this deployment. 
  - Edit the ``terraform.tf`` file and change line 15 to read: ``required_version = ">= 1.2"``
- You will also need to update the version for the `vpc` module as follows:
  - Edit the `main.tf` file. 
  - Find the `module "vpc"` block.
  - Change the `version` argument to match:

  ```yaml
  version = "4.0.2"
  ```

## 2. Protect Sensitive Input Variables (20-30mins)
- In the following tutorial the "Set values with environment variables" section requires setting environment variables. On your VMs this is best done in a windows PowerShell. Using the VSCode desktop, open a PowerShell by clicking on the down arrow beside the + on the top right of your bash terminal. Then following the Windows PowerShell instructions in the tutorial
- https://learn.hashicorp.com/tutorials/terraform/sensitive-variables?in=terraform/configuration-language 
- You will need to change the required_version of Terraform in this deployment. 
  - Edit the ``terraform.tf`` file and change line 15 to read: ``required_version = ">= 1.2"``

## 3. Output Data from Terraform (20mins)
- https://learn.hashicorp.com/tutorials/terraform/outputs

## 4. Simplify Terraform Configuration with Locals
- https://learn.hashicorp.com/tutorials/terraform/locals?in=terraform/configuration-language
- For this lab you will also need to edit the ``required_version`` in the ``terraform.tf`` file as we have seen before.

## 5. Customize Terraform Configuration with Variables (20mins)
- https://learn.hashicorp.com/tutorials/terraform/variables?in=terraform/configuration-language

## 6. Build and Use a Local Module (15mins)
- the git repository for this tutorial actually has all the solution code already entered, so you just need to go through an verify you understand each step. 
- Note that you must set your bucket name to a *unique*, valid S3 bucket, you will need to change the code at this point. 
- In your Git bash shell on your Windows VM you can verify your website using the command:
  ``start chrome https://$(terraform output -raw website_bucket_name).s3-us-west-2.amazonaws.com/index.html`` 
  or
  ``curl https://$(terraform output -raw website_bucket_name).s3-us-west-2.amazonaws.com/index.html`` 
  on any other platform.
- https://learn.hashicorp.com/tutorials/terraform/module-create?in=terraform/modules

## 7. Refactor a Monolithic Terraform Configuration (20mins)
- This tutorial offers you an interactive terminal, if it does not launch just use your normal VM environment.
- https://learn.hashicorp.com/tutorials/terraform/organize-configuration?in=terraform/modules

## 8. Use Configuration to Move Resources (20mins)
- https://learn.hashicorp.com/tutorials/terraform/move-config?in=terraform/configuration-language 
## 9. Develop Configuration with the Console (15mins)
- This tutorial uses the Terraform Console to develop an access policy for an S3 bucket so the contents can only be accessible from the IP address of your VM. 
- The terraform console does not provide much command line interaction (no history, no cursor movement with arrow keys etc).
- On your VMs you may find ``terraform init`` fails because of a versioning problem. If you proceed with ``terraform init -upgrade`` it should work fine.
- In the ``main.tf`` file the line ``acl = "private" `` in the ``aws_s3_bucket`` resource is not compatible with the upgraded version of terraform (it is automatically put in on creation). Change this to ``acl = null`` before applying the configuration.
- https://learn.hashicorp.com/tutorials/terraform/console 

## 10. Create Dynamic Expressions (20mins)
- https://learn.hashicorp.com/tutorials/terraform/expressions?in=terraform/configuration-language 
- For this lab you will also need to edit the ``required_version`` in the ``terraform.tf`` file as we have seen before.

## 11. Perform Dynamic Operations with Functions (15mins)
- With this (and other) tutorials that produce an example website you can use to test you deployment, note that it can take some time for your AWS resources to spin up. If you open a browser at the provided link, it will usually refresh after a while and show your deployed site.
- In the following tutorial, the section on SSH keys for ``Mac or Linux command-line`` can be followed using a Git Bash shell. There is no need to install PuTTY.
- https://learn.hashicorp.com/tutorials/terraform/functions?in=terraform/configuration-language
- For this lab you will also need to edit the ``required_version`` in the ``terraform.tf`` file as we have seen before.
