domain      = "sonalake"
environment = "dev"
role        = "mhryb"

service_name = "hello-world"
app = {
  port                = 8080,
  ingress_cidr_blocks = ["75.2.60.0/24"]
}
db = {
  name     = "postgres"
  username = "postgres"
  password = "postgres"
}