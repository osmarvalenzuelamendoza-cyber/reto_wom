# 📘 README – Proyecto GCS → Pub/Sub → Cloud Function → GCS (CSV RAW)

## ✅ Objetivo
Este proyecto despliega una arquitectura orientada a eventos donde:
- Al subir un archivo `.json` a un bucket (`entrada-json`), se genera un evento
- El evento se publica en un tópico Pub/Sub (`json-ingest-events`)
- Una Cloud Function (`procesar_json`) se activa, procesa el JSON con `pandas`, y genera un `.csv`
- El archivo transformado se guarda en `salida-raw/capa-raw/`

---

## 🚀 Paso a paso para ejecutar desde cero

### 🔐 1. Autenticación y configuración de GCP
```bash
  gcloud auth login
  gcloud auth application-default login
  gcloud config set project gothic-victor-470918-u3 -- AQUI VA EL PROJECT_ID
  gcloud auth application-default set-quota-project gothic-victor-470918-u3 -- AQUI VA EL PROJECT_ID
```

---

### ⚙️ 2. Habilitar APIs necesarias
```bash
gcloud services enable \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  pubsub.googleapis.com \
  storage.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  artifactregistry.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  --project=gothic-victor-470918-u3
```

---

### 📦 3. Crear entorno Python y empaquetar la función
```bash
# En raíz del proyecto
python3 -m venv .venv
source .venv/bin/activate
pip install -r cloud_function/requirements.txt

# Empaquetar la función
cd cloud_function
zip -r ../templates/cloud_function_source.zip .
cd ..
```

---

### 🏗 4. Inicializar Terraform y aplicar
```bash
cd infra
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

---

### 🧪 5. Probar flujo completo
```bash
# Crear un archivo JSON válido
printf '{"user_id": 1, "event": "login"}\n{"user_id": 2, "event": "checkout"}\n' > test.json

# Subir al bucket de entrada
gsutil cp sample.json gs://entrada-json/

# Verificar en bucket de salida
gsutil ls gs://salida-raw/capa-raw/
gsutil cat gs://salida-raw/capa-raw/sample.csv
```
---

## 🧼 Limpieza del entorno (opcional)
```bash
terraform destroy -var-file="terraform.tfvars" -auto-approve

gcloud functions delete procesar_json --region=us-central1 --gen2 --quiet || true
gcloud pubsub topics delete json-ingest-events --quiet || true
gsutil -m rm -r gs://entrada-json || true
gsutil -m rm -r gs://salida-raw || true
gcloud storage buckets delete gs://entrada-json --quiet || true
gcloud storage buckets delete gs://salida-raw --quiet || true
```
