provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "project" {}


resource "google_storage_bucket" "input" {
  name     = var.bucket_input
  location = var.region
}

resource "google_storage_bucket" "output" {
  name     = var.bucket_output
  location = var.region
}

resource "google_pubsub_topic" "topic" {
  name = var.topic_name
}

resource "google_storage_notification" "notify_pubsub" {
  bucket         = google_storage_bucket.input.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic.id
  event_types    = ["OBJECT_FINALIZE"]

  depends_on = [
    google_pubsub_topic.topic,
    google_pubsub_topic_iam_member.allow_gcs_publish
  ]
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "cloud_function_source.zip"
  bucket = google_storage_bucket.input.name
  source = "../templates/cloud_function_source.zip"
}

resource "google_cloudfunctions2_function" "function" {
  name     = var.function_name
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.input.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    timeout_seconds    = 60
    available_memory   = "512M"
    environment_variables = {
      RAW_BUCKET = var.bucket_output
    }
  }

  event_trigger {
    event_type    = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic  = google_pubsub_topic.topic.id
  }
}

resource "google_project_iam_member" "cloudfn_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_cloudfunctions2_function.function.service_config[0].service_account_email}"
}

resource "google_project_iam_member" "cloudfn_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_cloudfunctions2_function.function.service_config[0].service_account_email}"
}

resource "google_pubsub_topic_iam_member" "allow_gcs_publish" {
  project = var.project_id
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}
