# Exercise 7 Terraform S3 Backend Configuration (30 mins)

* For this exercise we will use the AWS web console to create and configure and Amazon S3 bucket to be used as a Terraform Backend. 

* **Note** that it is not recommended to create the necessary AWS backend resources as part of the configuration you are deploying since a terraform destroy will also destroy your backend. 
  * These resources need to be created and managed independently. 
  * While we use the AWS console here, clearly these resources could also be created using the CLI. 

## Step 1: Create an S3 Bucket
*	Open a browser in your vm and navigate to https://console.aws.amazon.com.
*	Sign in using the credentials you have been using for the AWS CLI
*	In the search box at the top type `S3` and choose the S3 service.
*	Click on `Create Bucket` and choose a bucket name (which must be unique) and a region.
*	Scroll down and under `Bucket Versioning` select `Enable`
*	Leave the rest of the options as their defaults and click `Create Bucket` at the bottom

## Step 2: Modify the Bucket Policy
*	Click on your new bucket in the list of S3 buckets
*	Look under the `Properties` tab of your bucket to find the ARN of your bucket and copy that to a text editor like Notepad.
*	From a git bash command line run the aws command to get your user ARN and copy it to the same text editor (Copy in a Git Bash shell can be achieved by selecting with the mouse and typing CTRL+INSERT to copy the text to the clipboard):

```bash
aws sts get-caller-identity --output json
```

*	Now  go to the `Permissions` tab of your S3 bucket, scroll down to the `Bucket Policy` box and click `Edit`
*	Amend the policy to match the policy below (there is an example in the folder with this document that you can use), substituting your user ARN and S3 ARN, then click `Save Changes` at the bottom :

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "<your_user_arn>"
            },
            "Action": "s3:ListBucket",
            "Resource": "<your_bucket_arn>"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "<your_user_arn>"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "<your_bucket_arn>/*"
        }
    ]
}
```
 
## Step 3: Create a DynamoDB Table
*	One of the big advantages of using an S3 bucket as a Terraform backend is that it means multiple team members can modify the state files without causing conflicts.
*	If this is to work, we need to consider what would happen if two people try to modify the state file at the same time. 
  * For some backends (including S3 buckets) Terraform allows state locking – which prevents write operations on a state file while other write operations are happening. 
  *	For an S3 bucket we need to supply a database to lock out state – we will use a DynamoDB table. 
*	Search for `DynamodDB` in your AWS console and click to create a new table
*	Scroll down and find the orange `Create Table` button
*	Name the table anything you like, but set the Partition key string to LockID. Leave the remaining setting as they  are and click the `Create table` button on the bottom right.

## Step 4: Hook up your Terraform configuration

*	You can use any of your existing Terraform root modules for this – if you are unsure just use the `terraform-configure-s3-backend` configuration in the labs/student directory on the website. 
*	Update the Terraform block in main.tf as follows (using your own bucket_name, region and DynamoDB table name):
  * Note that the region must be the region code of your bucket and DynamoDB table, like `eu-west-2` for London, not `London`

```yaml
terraform {
  backend "s3" {
    bucket         = "<your_bucket_name>"
    key            = "terraform.tfstate"
    region         = "<your_aws_region>"
    dynamodb_table = "<your_dynamo_dbtable_name>"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
```

## Step 6: Initialize the Terraform S3 Backend

*	This is done as usual with `terraform init`:

```bash
$ terraform init

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.27"...
- Installing hashicorp/aws v3.74.3...
- Installed hashicorp/aws v3.74.3 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider selections it made above. Include this file in your version control repository so that Terraform can guarantee to make the same selections by default when you run "terraform init" in the future.

Terraform has been successfully initialized!

```

* You may now begin working with Terraform. Try running `terraform plan` to see any changes that are required for your infrastructure. All Terraform commands should now work.
* If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other commands will detect it and remind you to do so if necessary.

## Step 7: Apply your changes
*	This will create your EC2 instance and save the Terraform state to your S3 Bucket.
*	Type `terraform apply` in your git bash command line. Remember to respond `yes` to the prompt to create resources.
*	Once creation is complete, go to your AWS Console and locate your S3 Terraform backend. Click on it to see that the terraform.tfstate file is saved in the bucket.
*	You can click on the file and choose the `Open` button to see the file contents.

## Step 8: Cleanup Resources
* The cleanup is in 2 stages, mirroring the creation sequence - first you need to cleanup the resources deployed using Terraform, then you need to manually delete your AWS resources.

### 8.1 Cleanup Terraform Resources
*	Run `terraform destroy` from the git bash command line, remembering to type `yes` at the prompt.
*	Note that the terraform.tfstate file still exists in your S3 bucket. It will persist as it is created and managed independently of your Terraform configuration.

### 8.2 Cleanup AWS Resources

*	To remove your AWS resources you will need to delete them manually using the console.
* 	For the S3 bucket:
  *  Click the `Buckets` link on the left-hand navigation panel of the Amazon S3 Console page.
  * Select the radio button next to your S3 bucket and click the `Empty` button. Follow the instructions.
  * Repeat this process above and click the `Delete` button.

* 	For the DynamoDB table:
  * Click the `Tables` link on the left-hand navigation panel of the DynamoDB Console page.
  * Select the check box next to your DynamoDB table and click the `Delete` button.
