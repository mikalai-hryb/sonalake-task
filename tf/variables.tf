##############################################################################
### General variables
##############################################################################

variable "domain" {
  description = "Domain of an application."
  type        = string
}

variable "environment" {
  description = "Short environment name."
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Invalid var.environment value. Allowed: dev, qa, prod."
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "role" {
  description = "Application Role."
  type        = string
}

##############################################################################
### Module specific variables
##############################################################################

variable "service_name" {
  description = "ECS Service Name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID. Defaults to the default VPC."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 Instance Type."
  type        = string
  default     = "t3.micro"
}

variable "app" {
  description = "Application settings."
  type = object({
    port                = optional(number, 443)
    protocol            = optional(string, "HTTPS")
    ingress_cidr_blocks = optional(list(string), [])
  })
  validation {
    condition     = contains(["HTTPS"], var.app.protocol)
    error_message = "Invalid var.app.protocol value. Supported: HTTPS."
  }
}

variable "db" {
  description = "Database settings."
  type = object({
    allocated_storage    = optional(number, 20)
    engine               = optional(string, "postgres")
    engine_version       = optional(string, "16.3")
    instance_class       = optional(string, "db.t3.micro")
    parameter_group_name = optional(string, "default.postgres16")
    port                 = optional(number, 5432)
    name                 = string
    username             = string
    password             = string
  })
  sensitive = true
}

