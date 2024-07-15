# Terraform

## Naming convention

You can notice that almost all the terraform resources have name `"this"`.

I did it on purpose because the root module creates resources in a single instance.

## Module vs plain configuration

I use plain Terraform configuration instead of packing everything in a module. It is just for simplicity.

For production, I would highly recommend to create a standalone module for a service and use it in a necessary microservice.
Also it makes sense to split all the resources into 2 configurations - global and env-specific.

The "global" configuration should contain common resources for many services, for example, ECS Cluster, Load Balancer, CloudWatch Log Group, RDS, ...

The "env-specific" configuration should contain the ECS Service, IAM roles, ECR Repository, ...

## Get rid of hardcoding

Currently there is no possibility to tune some aspects of the configuration without modifying the configuration itself.

For example, Target Group health check, Auto Scaling, Task Definition, Security Groups, IAM permissions.

To improve configuration more input variables should be added.

## Backend

I use `local` backend for this task.

For production, it must be different but which supports encryption and locking mechanism.
It makes sense to use `S3` because it supports both features.

## Subnets

I search subnets by VPC ID for simplicity.

For production, the design of VPC should be thought out carefully.

It's a good practice to search subnets by tags.

## Cluster

I create an ECS Cluster within this configuration because we need a cluster.

For production, I would recommend to create ECS Cluster outside of this configuration and to pass the Cluster Name as an input variable to an ECS Service module as well as other "global" resources.

### EC2 vs Fargate

The use of EC2 or Fargate compute option depends on a use case.
The Fargate option is easier to implement but it does not give you control on the running environment compared to EC2 option.

For production, from my experience, big companies prefer EC2 option because they are interested in using "prepared" machines with pre-installed stuff (building AMIs) or install it on-fly (using user data).

## Auto Scaling

I would say there are 2 types of auto scaling in context of ECS.

1. Auto scaling groups which scale the number of EC2 machines for you Cluster if EC2 compute option is used.

2. ECS auto scaling which scales the number of ECS tasks with the help of CloudWatch Alarms.

I added only autoscaling groups for simplicity. And hardcoded some settings.

For production, I highly recommend to configure both types of auto scaling and make it configurable.

## HTTPS

To serve traffic over HTTPS I have created a self-signed certificate using these links:

* [https://gist.github.com/riandyrn/049eaab390f604eae4bf2dfcc50fbab7]
* [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate#existing-certificate-body-import]

## ECS

### General recommendations for ECS

1. to update the application soothly in the future it makes sense to add blue-green deployment
2. set dependency between RDS and ECS Service (service depends on DB)

## RDS

### Design

I create single-az DB instance.

Improvement: It's better to create a multi-az DB Cluster or multi-az DB Instance.

### Destroying

To prevent losing DB data we can either `skip_final_snapshot = false` or `lifecycle.prevent_destroy = true`.

### General recommendations for RDS

1. if DB configuration is needed it makes sense to create a custom parameter group
2. set Maintenance Window
3. set max_allocated_storage
4. use gp3 storage type
5. enable storage encryption
6. enable backups
7. store DB password in Secret Manager Service or another place

## EC2

### General recommendations for EC2

1. allow `SSH` connection to EC2 machines from specific IP addresses
2. use gp3 volumes
3. add Terraform Check to make sure EC2 instances have access to the RDS

## IAM

### General recommendations for IAM

1. define inline polices instead of using managed polices in order to follow least privilege principle
