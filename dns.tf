data "google_dns_managed_zone" "env_dns_zone" {
  name = "my-cloudrroot7-domain-zone"
}

resource "google_dns_record_set" "api_invy_app_com" {
  name = "cloudrun.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
  type = "CNAME"
  ttl  = 86400

  managed_zone = data.google_dns_managed_zone.env_dns_zone.name

  rrdatas = ["ghs.googlehosted.com."]

  lifecycle {
    prevent_destroy = false
  }
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "60s"
}

resource "google_cloud_run_domain_mapping" "default" {
  location = var.region
  name     = "cloudrun.cloudroot7.xyz"

  metadata {
    namespace = "mytesting-400910"
  }

  spec {
    force_override = true
    route_name     = google_cloud_run_v2_service.cloud_run_teraform.name
  }

  depends_on = [
    # google_project_service.cloud_run_api,
    # google_dns_record_set.api_invy_app_com,
    # google_cloud_run_service_iam_policy.noauth,
    time_sleep.wait_30_seconds
  ]

}