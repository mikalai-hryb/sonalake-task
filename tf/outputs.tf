output "app_url" {
  description = "Application URL"
  value       = local.app_url
}

output "db_connection" {
  description = "The psql command to connect to DB"
  value = join(" ", [
    "psql",
    "--host=${aws_db_instance.this.address}",
    "--port=${aws_db_instance.this.port}",
    "--username=${aws_db_instance.this.username}",
    "--dbname=${aws_db_instance.this.db_name}"
  ])
  sensitive = true
}

output "image" {
  value = docker_image.this.name
}

output "my_ip" {
  value     = local.my_ip
  sensitive = true
}