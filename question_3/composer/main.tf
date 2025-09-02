provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "composer_dags" {
  name     = var.gcs_dag_bucket
  location = var.region
  uniform_bucket_level_access = true
}

resource "google_composer_environment" "composer_env" {
  name   = var.composer_env_name
  region = var.region

  config {
    software_config {
      image_version = "composer-2.14.0-airflow-2.10.5"
      env_variables = {
        AIRFLOW_VAR_PROJECT_ID   = var.project_id
        AIRFLOW_VAR_BQ_LOCATION  = var.bq_location
      }
    }

    workloads_config {
      scheduler {
        cpu        = 1
        memory_gb  = 3
        storage_gb = 1
        count      = 1
      }
      web_server {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
      }
      worker {
        cpu        = 2
        memory_gb  = 4
        storage_gb = 5
        min_count  = 1
        max_count  = 3
      }
    }

    node_config {
      service_account = "composer-env-sa@gothic-victor-470918-u3.iam.gserviceaccount.com"
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
  }
}
