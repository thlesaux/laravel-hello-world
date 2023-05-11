# Configure GCP project
provider "google" {
  project = "laravel-hello-world-384413"
}
# Deploy image to Cloud Run
resource "google_cloud_run_service" "webapp" {
  name     = "webapp"
  location = "europe-west9"
  template {
    spec {
      containers {
        image = "eu.gcr.io/laravel-hello-world-384413/webapp"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
# Create public access
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
# Enable public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.webapp.location
  project     = google_cloud_run_service.webapp.project
  service     = google_cloud_run_service.webapp.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
# Return service URL
output "url" {
  value = google_cloud_run_service.webapp.status[0].url
}