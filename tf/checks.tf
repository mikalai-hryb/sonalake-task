check "app_health" {
  data "http" "app" {
    url      = "${local.app_url}/health"
    insecure = true
    # request_timeout_ms = 10 * 1000 # https://github.com/hashicorp/terraform-provider-http/issues/402
  }

  assert {
    condition     = data.http.app.status_code == 200
    error_message = "${data.http.app.url} returned an unhealthy status code"
  }
}