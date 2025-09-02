# Paso 2 – CI/CD: Despliegue de Cloud Function con Terraform (GitHub Actions)

Este paso configura un pipeline en **GitHub Actions** que, al hacer un `git push`, empaqueta la Cloud Function y ejecuta `terraform apply` para desplegarla en Google Cloud.

---

## 🚀 ¿Qué hace?

Cada vez que haces un `git push` a `main` o `master`, el pipeline:

1. Empaqueta el código de la función (`cloud_function/`)
2. Ejecuta Terraform (`terraform apply`) para crear o actualizar los recursos en GCP

---

## 🔐 Requisitos

Debes crear una **Service Account** en GCP con permisos suficientes (por ejemplo: `roles/editor` o mínimo `cloudfunctions.admin`, `storage.admin`, `iam.serviceAccountUser`).

Luego:

1. Descarga el archivo `key.json` de esa Service Account
2. Crea los siguientes **GitHub Secrets** en tu repositorio:

| Nombre del Secret     | Descripción                          |
|------------------------|--------------------------------------|
| `GOOGLE_CREDENTIALS`  | Contenido completo del `key.json`    |
| `PROJECT_ID`          | ID de tu proyecto en GCP             |
| `REGION`              | Región donde se despliega (ej: `us-central1`) |

---

## 📁 Ubicación del pipeline

El archivo del pipeline se encuentra en:

