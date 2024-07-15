# Sonalake Task

Here is you can find

* a simple Flask (Python) application
* a Dockerfile to build a Docker image
* Terraform configuration to deploy the application into AWS ECS Service

The main parts of infrastructure are

* Auto Scaling Group
* ECS Cluster and ECS Service
* Load Balancer
* RDS

After deployment the application is accessible from your IP address over HTTPS.

## Review AWS infrastructure using Terraform configuration

You can find more information about the AWS infrastructure for this application in this [README.md](./tf/README.md) file

## Prerequisites

* Terraform 1.9+

I recommend using [tfenv](https://github.com/tfutils/tfenv?tab=readme-ov-file#installation) to manage TF versions

## Deploy infrastructure

1. Clone the repository
2. Go to the folder with Terraform configuration

   ```bash
   cd tf
   ```

3. Update [terraform.tfvars](./tf/terraform.tfvars) if needed
4. Run TF configuration

   Do not forget to review the plan and respond to the confirmation prompt with `yes`

   ```bash
   terraform apply
   ```

## Testing

### Application is up and running

1. Run from `tf` folder after successful deployment

   ```bash
   curl --insecure $(terraform output -raw app_url)
   ```

### RDS access

1. Connect to an EC2 instance
   1. chose a running EC2 instance
   2. click `Connect`
   3. go to `Session Manager` tab
   4. click `Connect`

2. Install the `psql` client to EC2 instance

   [You most likely need a command for Amazon Linux 2](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToPostgreSQLInstance.html#install-psql)
3. Get a `psql` command to run
   1. Run from `tf` folder

   ```bash
   terraform output -raw db_connection
   ```

4. Connect to PostgreSQL DB
   1. run the command from the previous step inside EC2 instance
   2. find the password in the [terraform.tfvars](./tf/terraform.tfvars) file

## Clean Up

1. Go to AWS account and set both `Minimum capacity` and `Desired capacity` to `0`

   This manual step is needed because `aws_autoscaling_group.protect_from_scale_in = true`

2. Run Terraform

   Do not forget to review the plan and respond to the confirmation prompt with `yes`

   ```bash
   terraform destroy
   ```
