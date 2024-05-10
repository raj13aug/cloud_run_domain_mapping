data "google_dns_managed_zone" "env_dns_zone" {
  name = "my-cloudrroot7-domain-zone"
}


resource "google_dns_record_set" "default" {
  name         = "cloudrun.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.demo.network_interface[0].access_config[0].nat_ip
  ]
}

resource "google_cloud_run_domain_mapping" "default" {
  location = var.region
  name     = "my-cloudrroot7-domain-zone"

  metadata {
    namespace = "my-project-name"
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }
}