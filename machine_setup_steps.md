
# Step 1 - Terraform Install
- Install terraform using chocolatey on the (windows) VMs, and configure the auto-complete option.
- Just in case someone wants to use Terraform on the WSL rather that on native windows, install Terraform on the Ubuntu shell as well as in windows proper. Instructions are at https://learn.hashicorp.com/tutorials/terraform/install-cli

# Step 2 - AWS accounts
- Create a user group on AWS IAM that has the following permissions:

```  
        AmazonVPCFullAccess
        AmazonEC2FullAccess
        AmazonS3FullAccess
        AmazonRDSFullAccess
        AmazonDynamoDBFullAccess
        EC2InstanceConnect # this is just if you need to log into the EC2 instance to debug
```

- It is worth creating an IAM policy that allows them to list and browse IAM, but only change their own password and create/update/delete their own access keys:
```
        {
        "Version": "2012-10-17",
        "Statement": [
        {
        "Effect": "Allow",
        "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GenerateCredentialReport",
        "iam:GenerateServiceLastAccessedDetails",
        "iam:Get*",
        "iam:List*",
        "iam:PassRole",
        "iam:SimulateCustomPolicy",
        "iam:SimulatePrincipalPolicy"
        ],
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
        "iam:ChangePassword",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey"
        ],
        "Resource": "arn:aws:iam::*:user/${aws:username}"
        }
        ]
        }
```
- The users have to a secret key from their AWS accounts and use it to configure the AWS CLI on a VM (note: this will be deleted before the machine image is frozen.)
- The main AWS account that is used will also need some quotas increased - VPCs to 20 per region, and EIPs to 100 per region, NAT gateways 20 per AZ. Also need to activate all regions. 


# Step 3 - Docker (Windows Server 2019 Specific)
- Docker on the Windows Server 2019 version we have on the VMs is problematic 
- the VMs do not have Hyper-V capability, so Docker Desktop will not function, which means the only way to run Docker is with native windows containers. 
- I have tried to get full functionality for Docker on Windows using the steps in https://blog.sixeyed.com/getting-started-with-docker-on-windows-server-2019/
- It does mean Linux native containers like ``nginx`` will not work. I have replaced these with windows containers in the examples. 

# Step 4 - docker-compose
This is required for one of the tutorials 
- web page https://docs.docker.com/compose/install/, look under Windows Server
- In a PowerShell running as Administrator: 
```
$ SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe
```
- test installation:
```
$ docker-compose --version
```

# Step 5 - ngrok (Webhooks demo)
This step is necessary for the webhooks demo - you need to supply a payload URL to receive the Webhook POST request on the VMs.
- I followed the suggestions at https://docs.github.com/en/github-ae@latest/developers/webhooks-and-events/webhooks/creating-webhooks
- For the VMs I installed ngrok on Windows (https://ngrok.com/download), but found the Ruby install needed for Sinatra just wasn't sufficient on the Windows side, so I installed Ruby in the Ubuntu shell and it worked fine. There is a weird windows bug in the Ubuntu shell - the workaround fix was ``export TERM=xterm-color``. Apparently MS will release a proper fix soon.
  
# Step 6 - Ansible installation (and AWS on the WSL)
- This is necessary for the Ansible tutorials
- It can only be installed on the WSL, so you have to use the Ubuntu shell of the Windows Server 2019 machines
```
        $sudo apt update; sudo apt install ansible
        $sudo apt install python3-pip # need the pip package to install boto3
        $sudo pip3 install boto boto3
        $sudo apt install awscli
```
- Then create a user for Ansible:
```
        $ useradd --create-home --shell /usr/bin/bash ansible
        $ passwd ansible
```
- password for ansible is ``c0nygre``
- Note when you login to the ansible account, I have set the TERM environment variable to vt220 in the .bashrc file. This fixes a scroll bug - when you clear the screen the prompt disappears and you can't see anything you type. With the vt220 TERM all seems to function normally.
- Also seems like a good idea to add ansible to the sudoer group:
```
        $ usermod -aG sudo ansible 
```
- Then edit the ``/etc/sudoers`` file so sudo users don't need to supply a password
```
        $sudo vi /etc/sudoers
```
- change the line that starts ``%sudo`` to 
```
        %sudo	ALL=(ALL:ALL) NOPASSWD:ALL
```
- It works best if localhost is added to the ansible hosts list
```
        $ sudo vi /etc/ansible/hosts 
```
- then append the following lines to the end of the file:
```
        [mylocalhost]
        localhost ansible_connection=local
```

# Step 7 - MySQL
- add the mysql.exe path to the PATH variable in git bash:
```
        $ export PATH=/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin:$PATH
```
- This is necessary in the database creation configurations because they rely on a local-exec of the mysql command.
- If you want to use MySQL in the WSL you have to install it directly. 

# Using the CLIs
## You will need to help them decide which shell they are going to use. Most of what we will do will be through the command line. I have been using Git Bash and PowerShell with no problems. 

# Step 8 - CDKTF installation (Not Used)
- This is a package to automatically transfer between other languages and HCL. 
- Installed for the JSON encoding demo
```
        $ npm install --global cdktf-cli@latest
```

# Step 9 - Check Tutorial Links
- Check the urls in the autoscaling-ec2 demo, (tf and instructions), and the project solutions and readme. Make sure they point to something that actually is live! Both the website to curl the jar files and the database website. 

# TIDY UP FOR A MACHINE THAT WILL BE RE-USED
1. delete ~/.aws/credentials
2. delete ~/terraform
3. delete ~/terraform-3day
4. from the ansible user in the ubuntu shell: delete ~/.aws/credentials
5. Clear out the Downloads folder and empty the trash
