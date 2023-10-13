# Exercise 5 The Terraform Configuration Language I
This exercise combines a series of Hashcorp Terraform tutorials that cover some of the configuration language features we have learned so far.
## 1. Define Infrastructure with Terraform Resources (20-30min)
- https://learn.hashicorp.com/tutorials/terraform/resource?in=terraform/configuration-language
- This tutorial will work fine on our systems, but needs a small edit to run.  
  - The Terraform version is set to a minor release prior to the one we are using. 
  - To update it, edit the ``terraform.tf`` file, and change the ``required_version`` on line 22 to be ``~> 1.5.0``. 
- Note that the tutorial has instructions for both ``Terraform Community Edition`` and ``Terraform Cloud``. We will follow the ``Terraform Community Edition`` instructions.

## 2. Manage Similar Resources with Count (20mins)
- https://learn.hashicorp.com/tutorials/terraform/count?in=terraform/configuration-language
- For this to initialize with our version of Terraform we need to edit the ``terraform.tf`` file and change line 15 to read ``required_version = ">= 1.2"``
- Remember to follow the instructions for ``Terraform Community Edition``

## 3. Advanced! Manage Similar Resources with For Each (45mins)
- this is quite an advanced tutorial - it doesn't describe very clearly *how* to separate the EC2 instances out into a separate module. It is worth trying it yourself from the tutorial description, and then cloning the solution repository to compare your files if you are not able to get it working successfully.
- https://learn.hashicorp.com/tutorials/terraform/for-each?in=terraform/configuration-language
- Once again you need to edit the ``terraform.tf`` file and change line 15 to ``required_version = ">= 1.2"``
