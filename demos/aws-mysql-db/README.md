# Provision and Initialize a MySQL Database using Terraform
This tutorial follows closely the Terraform tutorial at https://learn.hashicorp.com/tutorials/terraform/aws-rds?in=terraform/aws. The differences are as follows:
1. Instead of a postgreSQL database we will provision a MySQL database. This requires setting the ``engine`` to "mysql", and the ``engine_version`` to "8.0.28".
2. The ``aws_db_parameter_group`` resource does not have appropriate parameters for MySQL. You can either talk about parameter groups and go through the process of creating a MySQL parameter group (best to create a dummy one in the console to find out which arguments you'd like to use) to determine which parameters you'd like to control, or you can just comment out the parameter group altogether and ignore that section.
3. To initialize the database with a MySQL Schema ``schema.sql`` you need to add the following command to the ``aws_db_instance`` block:

```

  provisioner "local-exec" {
    command = "mysql --host=${self.address} --port=${self.port} --user=${self.username} --password=${self.password} < ./schema.sql"
  }
  ```
  In most cases this will provision your database exactly as needs be, however it can happen that Terraform attempts to run local-exec before the database is fully deployed, resulting in an error. The solution to this is a commonly used hack, in which a null resource is created that depends_on the database, and the local script is executed in that resource. In this case, rather than putting the ``local-exec`` block above in the ``db`` block, you add a new block as follows:

  ```
  resource "null_resource" "db_setup" {
    depends_on = [aws_db_instance.db] #wait for the db to be ready
    provisioner "local-exec" {
      command = "mysql --host=${aws_db_instance.db.address} --port=${aws_db_instance.db.port} --user=${var.db_username} --password=${var.db_password} < ./schema.sql"
    }
  }
  ```
  
  4. Make your database more portable by creating a suitable set of variables to auto-assign names to resources and remove any magic strings. 