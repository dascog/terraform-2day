# Exercise 1 First Terraform Deployment (20-30mins)

## 1. Download and unzip the 1-first-deployment directory 
Your instructor will provide you with a link. Put it somewhere accessible on your VM (like the desktop, or the C:\Users\Administrator directory). You may wish to create a directory like "terraform-learning" on your VM to collect the exercises. 
## 2. Open Visual Studio Code (or navigate from a command line)
* Double click on the icon on your desktop then use File->Open Folder to open the folder you just created.
* The folder has just this README.md file, and a single main.tf file, and a linux subdirectory with a second main.tf.
* If you prefer to navigate from a command line you can use PowerShell or Git Bash.
* If you are working on a Linux machine, navigate to the linux subdirectory. The instructions will still work, but you will deploy an nginx webserver on port 8000, rather than a microsoft web application.
## 3. Bring up a terminal in VS Code by Terminal->New Terminal
* If you are working from a command line, you don't need to do this.
## 4. Verify that terraform is installed
* On the command line run the command ``terraform -v``. 
* You should get the response ``Terraform v1.1.6 on windows_amd64``
## 5. Initialize Terraform in the current directory
* On the command line type `terraform init`. 
* You should see a green message telling you your initialization has been successful.
## 6. Apply the configuration
The main.tf file deploys an web application in a docker container on your VM. 
* Type `terraform apply` to do the deployment.
* Assuming all goes correctly, you will be prompted to indicate you want to create the resources. Type `yes`. 
* The application will then deploy and you should get a response like `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.`
## 7. Check your deployment 
* Navigate to localhost:8000 in your browser - you should see a message indicating your deployment is running.
* Alternatively you can type `curl http://localhost:8000` in the command line.
* Type `terraform show` in the command line to see the details of your deployment.
## 8. Clean up your resources
* With terraform cleaning up is easy! Just type `terraform destroy` in your command line.

# Congratulations! You have deployed your first application with Terraform!
