variable "project_id" {}
variable "region" { default = "us-central1" }
variable "composer_env_name" { default = "composer-etl-env" }
variable "gcs_dag_bucket" { default = "composer-dags-joshua" }
variable "bq_location" { default = "US" }
