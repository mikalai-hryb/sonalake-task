# build image locally
resource "docker_image" "this" {
  name = trimprefix("${data.aws_ecr_authorization_token.this.proxy_endpoint}/${aws_ecr_repository.this.name}:latest", "https://")
  build {
    context    = local.git_repo_root
    dockerfile = "${local.git_repo_root}/docker/Dockerfile"
  }

  # rebuild the docker image only if application files have changed
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.git_repo_root, "src/*") :
      filesha1("${local.git_repo_root}/${f}")
    ]))
  }
}

# push image to ECR
resource "docker_registry_image" "this" {
  name = docker_image.this.name
}
