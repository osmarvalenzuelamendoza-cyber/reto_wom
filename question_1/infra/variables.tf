variable "project_id" {}
variable "region" { default = "us-central1" }
variable "bucket_input" { default = "entrada-json" }
variable "bucket_output" { default = "salida-raw" }
variable "function_name" { default = "procesar_json" }
variable "topic_name" { default = "json-ingest-events" }
