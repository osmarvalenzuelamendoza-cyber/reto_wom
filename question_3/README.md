# ------------------------------------------
# Paso 1 – Autenticación y configuración
# ------------------------------------------

gcloud auth login
gcloud auth application-default login
gcloud config set project gothic-victor-470918-u3
gcloud auth application-default set-quota-project gothic-victor-470918-u3

# ------------------------------------------
# Paso 2 – Crear Service Account para Composer
# ------------------------------------------

PROJECT_ID="gothic-victor-470918-u3"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

gcloud iam service-accounts create composer-env-sa \
  --display-name "Composer Environment SA"

SA="composer-env-sa@$PROJECT_ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA" \
  --role="roles/composer.worker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA" \
  --role="roles/composer.environmentAndStorageObjectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA" \
  --role="roles/iam.serviceAccountUser"

# ------------------------------------------
# Paso 3 – Dar permisos al Service Agent interno de Composer
# ------------------------------------------

COMPOSER_AGENT="service-${PROJECT_NUMBER}@cloudcomposer-accounts.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$COMPOSER_AGENT" \
  --role="roles/composer.ServiceAgentV2Ext"

# ------------------------------------------
# Paso 4 – Habilitar APIs necesarias
# ------------------------------------------

gcloud services enable \
  composer.googleapis.com \
  bigquery.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  pubsub.googleapis.com \
  run.googleapis.com \
  container.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  iam.googleapis.com \
  --project=$PROJECT_ID

# ------------------------------------------
# Paso 5 – Desplegar entorno con Terraform
# ------------------------------------------

cd composer
terraform init
terraform apply -var-file="terraform.tfvars" -auto-approve

# ------------------------------------------
# Paso 6 – Subir el DAG al entorno Composer
# ------------------------------------------

gsutil cp dags/gcs_to_bq_transform_dag.py gs://composer-dags-joshua/dags/
