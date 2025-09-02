PREGUNTA: Justifique adecuadamente su arquitectura

# Justificación de la arquitectura

## Capacidad

- Con 10 req/s, la capacidad total es de 36,000 req/h.
- El promedio esperado es de 600/h (≈ 1/60 de la capacidad).
- Un burst de 600 registros se evacúa en aproximadamente 60 segundos a 10 req/s.
- El uso de Cloud Tasks asegura el cumplimiento del límite sin necesidad de throttling manual.

## Confiabilidad y resiliencia

- Cloud Tasks aporta reintentos, backoff exponencial y control de despacho → tolera fallas transitorias del proveedor.
- La DLQ (Dead Letter Queue) evita la pérdida de registros y permite reprocesos/auditoría.
- La idempotencia en el worker previene duplicados en caso de reintentos o redelivery.
- El uso de circuit breaker protege el sistema ante errores persistentes o indisponibilidad del proveedor.

## Operación & Costo

- Arquitectura serverless basada en Cloud Run y Cloud Tasks = pago por uso y bajo mantenimiento operativo.
- Observabilidad nativa mediante Logging y Monitoring.
- BigQuery centraliza analítica y cumplimiento de KPIs.

## Seguridad & Cumplimiento

- Uso de Secret Manager para credenciales.
- IAM mínimo, con privilegios reducidos por recurso.
- Cifrado CMEK y PAP aplicados a buckets.
- VPC egress con IP fija si el proveedor lo exige (allowlist).
- Webhook autenticado y firmado.
- Trazabilidad completa a través de logs y eventos en BigQuery.

## Evolutividad

- Separación clara de responsabilidades:
  - Ingesta / Validación
  - Orquestación
  - Ejecución
  - Callbacks

- Fácil de:
  - Escalar (ajustando `rate limit` de la cola),
  - Pausar (con detener Cloud Tasks),
  - Priorizar (con colas separadas por campaña o SLA).
