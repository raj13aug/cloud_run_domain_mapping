resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
}

resource "google_cloud_run_v2_service" "cloud_run_teraform" {
  name     = var.cloudrun_name
  location = var.region
  ingress  = var.cloudrun_ingress
  project  = var.project_id

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }


  template {
    containers {
      image = var.cloudrun_image
      resources {
        limits = {
          cpu    = "2"
          memory = "1024Mi"
        }
      }
      startup_probe {
        initial_delay_seconds = 2
        timeout_seconds       = 60
        period_seconds        = 5

        tcp_socket {
          port = 8080
        }
      }

    }
  }


  depends_on = [
    google_project_service.cloud_run_api
  ]
}


data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.cloud_run_teraform.location
  project     = google_cloud_run_v2_service.cloud_run_teraform.project
  service     = google_cloud_run_v2_service.cloud_run_teraform.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

output "url" {
  value = google_cloud_run_v2_service.cloud_run_teraform.uri
}