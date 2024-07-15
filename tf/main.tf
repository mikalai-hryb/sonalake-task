provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Name        = local.base_name
      Domain      = var.domain
    }
  }
}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.this.proxy_endpoint
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
  }
}

locals {
  git_repo_root = "${path.root}/.."

  base_name        = "${var.domain}-${var.environment}-${var.role}"
  base_name_prefix = "${substr(var.domain, 0, 5)}-"
  vpc_id           = data.aws_vpc.this.id
  container_port   = 80

  app_url = "${lower(var.app.protocol)}://${aws_lb.this.dns_name}:${var.app.port}"
  my_ip   = data.http.my_ip.response_body
}
