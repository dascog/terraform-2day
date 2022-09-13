# Exercise 3 AWS EC2 Deployment (20-30mins)
In this lab you will set up the AWS CLI so that you can manage AWS infrastructure with the Terraform command line. You will demonstrate this by deploying the EC2 image you saw in the teaching session. 

## 1. Generate you AWS Access Keys 
* Log into the AWS console  https://console.aws.amazon.com/console/home# either using your own account or one your instructor will supply. To set up CLI access you need quite high level access in your role, and Terraform will obviously need permissions to create the various resources you need.
* Click on your username in the top right corner of the screen to expose the drop down, then select the "Security Credentials" option.
* You cannot access the values of an existing access key directly, if there is one there then just create a second access key by clicking the "Create access key" button (you can have a maximum of 2 access keys per user account).
* Make sure you copy or save the access key details in a secure location.
## 2. Configure the AWS CLI
* Open up any windows command line terminal (PowerShell, Git Bash, cmd or the terminal in VS Code - NOT Ubuntu)
* Type the command `aws configure`
* Follow the prompts to copy in your Access Key ID and Secret Access Key. 
* You can either leave the Default region blank or type in `eu-west-1` which is the same region as the VMs.
* You can leave the default output blank. 
## 3. Unzip the lab directory (0.2-aws-ec2) to your VM and open the folder location in VS Code
* If you are working from a command line, you don't need to do this.
## 4. Open a terminal in VS Code 
* Terminal -> New Terminal
## 5. Now experiment with the terraform commands
* `terraform init`
* `terraform validate`
* `terraform plan`
* `terraform apply`
## 6. Check your deployment 
* Go to the AWS console in your web browser
* On the top right, next to your user name, set the region to Oregon (us-west-2) - this is the region we created the EC2 instance in.
* Find EC2 under the Services dropdown in the top-left of the screen.
* Your ExampleInstance should be displaying there. 
## 7. Modify your deployment
* Edit the main.tf file in VS Code.
* In the `resource` block add a new tag key-value pair under `Name`. You can call it anything you like. Make sure you save your changes!
* Run `terraform apply` again - you should be prompted to change 1 resource.
* Go back to the AWS EC2 console and refresh the instance.
* Click on the instance link and scroll down to the bottom of the page - on the right is a Tags tab, click on it, you should see your new tag. 
## 8. Clean up your resources
* `terraform destroy`
