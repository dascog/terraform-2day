# Exercise 4 Blue-Green and Canary Deployments (45mins)
This lab follows exactly one of the Terraform tutorials, however we note some minor changes for those deploying on the Windows VM environment

## 1. Open the Terraform Blue-Green Tutorial 
* This can be found at https://learn.hashicorp.com/tutorials/terraform/blue-green-canary-tests-deployments
* To clone the repository use a command line or windows explorer to navigate to the directory you want to put your repository in.
* If you are using windows explorer, right click in the directory and select "Git Bash Here" - this will open a Bash shell which you can use for the `git clone` command.
* Once the repository is cloned cd in to the repository directory and type the command `code .` to open VS Code in the current directory.
## 2. Update the required_version
* Open the `versions.tf` file in VS Code and update the `required version` statement to `required version = "~> 1.1.0"`.
## 3. Open up a Git bash terminal. 
* Some of the tutorial instructions require a linux command line. 
* If it's not already visible, open the Terminals frame using `CTRL '` or View -> Terminal.
* On the top-right of the Terminal frame the kind of shell you are using is displayed. If it is anything other than `bash`, click on the down arrow by the `+` sign and select the Git Bash option. 
## 4. Follow the instructions in the Tutorial
* All the instructions *should* execute as expected with the exception of the following corrections:
** In the `green.tf` file there is an error on line 8. The init-script filename should be `init-script.sh`.
## 8. Remember to clean up your resources before finishing
* `terraform destroy`
