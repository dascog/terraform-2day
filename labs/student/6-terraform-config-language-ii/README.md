# Exercise 6 The Terraform Configuration Language II
This exercise combines a series of Hashicorp Terraform tutorials that cover some of the configuration language features we have learned so far.

**NOTE**: Many of the Hashicorp tutorials will not run with current versions of Terraform or the AWS providers. Your trainer has selected a number of labs from the ones below and detailed changes required to get them working. The other labs are included for your reference and may be instructive - however there is no guarantee they will work without editing. You have been warned!

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
- In this tutorial you will enable output from a deployment and see the capability and limits of redacting sensitive outputs.
- https://learn.hashicorp.com/tutorials/terraform/outputs
- You will need to change the required_version of Terraform in this deployment. 
  - Edit the ``terraform.tf`` file and change line 21 to read: ``required_version = ">= 1.2"``

## 4. Simplify Terraform Configuration with Locals
- https://learn.hashicorp.com/tutorials/terraform/locals?in=terraform/configuration-language
- For this lab you will also need to edit the ``required_version`` in the ``terraform.tf`` file as we have seen before.

## 5. Customize Terraform Configuration with Variables (20mins)
- This is an excellent lab that will introduce you to all aspects of using variables in a terraform configuration.
- https://learn.hashicorp.com/tutorials/terraform/variables?in=terraform/configuration-language
- You will need to change the required_version of Terraform in this deployment. 
  - Edit the ``terraform.tf`` file and change line 20 to read: ``required_version = ">= 1.2"``

## 6. Build and Use a Local Module (30mins)
- The git repository for this tutorial actually has all the solution code already entered, so you just need to go through an verify you understand each step.
- The supplied code for the `aws-s3-static-website` module does not account for recent updates to S3 security policies and will fail to build. Please replace the contents of `modules\aws-s3-static-website-bucket\main.tf` with the following:

``` title="main.tf"
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  acl = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_bucket,
    aws_s3_bucket_public_access_block.s3_bucket,
  ]
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "${aws_s3_bucket.s3_bucket.arn}",
                "${aws_s3_bucket.s3_bucket.arn}/*"
            ]
        }
    ]
  })
}
```

- Note that you must set the bucket name in the `main.tf` `website_s3_bucket` block to a globally *unique*, valid S3 bucket name. You will need to edit the `website_s3_bucket` module block and change the `bucket_name` argument accordingly.
 
- In your Git bash shell on your Windows VM you can verify your website using the command:
  ``start chrome https://$(terraform output -raw website_bucket_name).s3-us-west-2.amazonaws.com/index.html`` 
  or
  ``curl https://$(terraform output -raw website_bucket_name).s3-us-west-2.amazonaws.com/index.html`` 
  on any other platform.
- https://learn.hashicorp.com/tutorials/terraform/module-create?in=terraform/modules
- You need to update some of the versions in the code. 
  - In the `main.tf` file, change the `version` in the `required_providers` block to `5.5.0`.
  - Then change the `version` argument in the `vpc` module block to be `5.1.2`.
  - And finally change the `version` argument in the `ec2_instances` module block to be `5.5.0`.
- **Please follow the cleanup instructions carefully**. This will save me manually deleting a whole lot of s3 buckets!

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
- The AMI image filters used the `aws_ami` data source is no longer supported.
  - In the `main.tf` file, locate the `aws_ami` data source and replace the block with the following:

```
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
```

- In a class setting you will encounter a conflict when creating multiple load balancers with the same name. 
  - Edit the `aws_elb` resource block in `main.tf` and add a unique string to the end of the `name` argument:

```
  name = "Learn-ELB-<YOUR-INITIALS>
```

- You will need to change the required_version of Terraform in this deployment. 
  - Edit the ``terraform.tf`` file and change line 20 to read: ``required_version = ">= 1.2"``

## 11. Perform Dynamic Operations with Functions (15mins)
- With this (and other) tutorials that produce an example website you can use to test you deployment, note that it can take some time for your AWS resources to spin up. If you open a browser at the provided link, it will usually refresh after a while and show your deployed site.
- In the following tutorial, the section on SSH keys for ``Mac or Linux command-line`` can be followed using a Git Bash shell. There is no need to install PuTTY.

- https://learn.hashicorp.com/tutorials/terraform/functions?in=terraform/configuration-language

- The AMI image filters used the `aws_ami` data source is no longer supported.
  - In the `main.tf` file, locate the `aws_ami` data source and replace the block with the following:

```
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
```
- The AMIs used in the **Use lookup function to select AMI** are also no longer current. Replace the suggested new `aws_amis` variable block in `variables.tf` with the following:

```
variable "aws_amis" {
  type = map
  default = {
    "us-east-1" = "ami-053b0d53c279acc90"
    "us-west-2" = "ami-03f65b8614a860c29"
    "us-east-2" = "ami-024e6efaf93d85776"
  }
}
```

- You will need to change the required_version of Terraform in this deployment. 
  - Edit the ``terraform.tf`` file and change line 20 to read: ``required_version = ">= 1.2"``
