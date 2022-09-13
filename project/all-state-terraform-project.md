# Deploy a Java Based Sprint Boot Application Using Terraform

To be completed in your breakout groups on the final afternoon.

This exercise gets more sophisticated as you proceed, you may not complete all the steps. 

1. First you will write a configuration that deploys a standalone Java Spring application that requires no database to an EC2 instance and run it, making sure it works. 
2. Then you will deploy the same app, but with a version that connects to an existing database. 
3. Then you will look at a configuration that creates an auto-scaled, load balanced deployment of the application.
4. Finally you will provision your own version of the database using Terraform, and modify your configuration to automatically connect to that database.


## Step 1: The Basic Application (no database)
The basic application can be found at https://tinyurl.com/CompactDiscRestNoDatabase. To deploy this you will need to 
- Create an aws_security_group resource with TCP ingress on port 8080, and open egress. 
- Provision an EC2 Amazon Linux instance (a t2.micro type is sufficient). 
- Run an initial setup shell script using the ``user_data=...`` argument to aws_instance. THe shell script needs to install an appropriate version of Java on the machine, then copy the application jar file to the local directory, and finally set the application running. The following shell script is an example

```
#!/bin/bash
yum update -y
yum -y install java-1.8.0
cd /home/ec2-user
wget https://tinyurl.com/CompactDiscRestNoDatabase
nohup java -jar CompactDiscRestNoDatabase > ec2dep.log
```

- You can verify the application is running by pointing your browser at ``http://<your-ec2-dns>:8080``.
- Destroy your resources afterwards, remembering to answer "yes" at the prompt. 
  
## Step 2: The Database Application Connected to an Existing Database
Databases tend to require persistent infrastructure and should be deployed independently of applications needing to access them. For this part of the project you should deploy an EC2 instance as you did in the previous section, but now with an application that requires access to a database to run. The application jar can be found at https://tinyurl.com/CompactDiscRestWithDatabase. 

To get the connection working properly you will need to create a file called 
``application.properties`` in the same directory as the jar file on your EC2 instance. This file should contain the following:

```
spring.datasource.url=jdbc:mysql://cloudessentialsworkshop.cfw1ttrlhzus.eu-west-2.rds.amazonaws.com:3306/conygre?useSSL=false
spring.datasource.username=root
spring.datasource.password=c0nygre1
```
- This application needs to have ``/api`` appended to its endpoint. So in this case you will have a URL that looks like ``http://<MY-EC2-URL>:8080/api`` as your endpoint. 
- Test you application as in the previous step. 
- Destroy your resources afterwards, remembering to answer "yes" at the prompt. 

## Step 3: The Database Application Behind an Elastic Load Balancer
In this step you will deploy exactly the same application setup as in the previous step, but this time it will deploy behind as instances spawned by an ELB. 
- You can use as a basis the demo walkthrough we did for deploying a load balanced app (under demo/autoscaling-ec2 on the website), together with your previous deployment.
- make sure that your load balancer health check target is set to ``HTTP:8080/api/`` which is the api destination page on the EC2 instances.
- The ELB redirects all traffic on its default HTTP port (port 80) to port 8080 of the instances. So to test your configuration you just need to put ``http://<your-elb-dns-name>/api`` in a browser and the REST output should come up. Note that Load Balancers can take quite a while to come up - you can check the health of the ELB instances by going to the EC2 page in the AWS console, then click on "Load Balancers" on the left hand panel, and find the "Monitoring" tab down the bottom. Refresh until you start to see the Healthy Hosts graph showing a positive number. 
- Destroy your resources afterwards, remembering to answer "yes" at the prompt. 

## Step 4: Deploy Your Own Database Using Terraform and Connect to Your Load-Balanced Application.
For this section you will provision your own version of the MySQL database (in a separate configuration), and use the outputs from that configuration (via terraform_remote_state) to set up the application.properties file for the instances in the auto-scaling group.
**Note** there seems to be an incompatibility between the versions of MySQL offered by AWS RDS, and the jar files we have access to. You are advised to use a MariaDB implementation (version 10.2.43 works fine) for your database instantiation. 
- First create your database configuration. You can use the demo walkthrough we did for deploying a MySQL database (under demo/aws-db-mysql), just use ``"mariadb"`` instead of ``"mysql"`` and set the engine_version to ``10.2.43``). We will use the same schema as in the demo, and you can access a MariaDB through the ``mysql`` command prompt so nothing needs to change there. Make sure your outputs include the ``rds_hostname``, the ``rds_port``, the ``rds_username`` and the  ``rds_password``.
- Now create a separate configuration for your auto-scaling application. You should begin with a copy of your previous load-balanced configuration. 
- In the launch configuration find where you wrote out the application.properties file. Clearly these parameters will change with your new database. You *could* just hardcode the values from your new database in, however you can make your configuration much more portable using a ``terraform_remote_state`` datasource to access the outputs of your database configuration. In the main.tf of your load-balanced application create a data source as follows:

```

data "terraform_remote_state" "db" {
  backend = "local"
  config = {
    path = "<RELATIVE_PATH_TO_YOUR_DB_TERRAFORM.TFSTATE_FILE>"
   }
}
```
- Edit the ``user_data`` argument of your ``aws_launch_configuration`` to access the database outputs at the relevant points. For example, your password line should look something like:

```
spring.datasource.password=${data.terraform_remote_state.db.outputs.rds_password}
```

- Make sure that you ``terraform apply`` your database first, and wait until it is up and running before applying your app configuration.
- You can test your deployment in the same way as your previous load-balanced deployment. 
- You must take care when destroying your resources to destroy the load-balanced deployment **first**, and only then destroy your database. Terraform uses the outputs of your database to determine the state of the configuration to destroy and will return an error if your database is destroyed prior to the load-balanced configuration.

## Optional Extra: Modules
If you have time you could try to format your ELB configuration as a module, and create a new parent configuration that calls that module, supplying the necessary variable values. 
