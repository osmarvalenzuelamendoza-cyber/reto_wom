PREGUNTA: Diseñe y diagrame una arquitectura

# Arquitectura propuesta (GCP)

## Supuestos

- Se generan 600 registros/hora.
- Límite del proveedor: 10 req/s.
- 600/h = 600 ÷ 3600 s = 0.1667 req/s (promedio) → muy por debajo de 10 req/s.
- Si llegan 600 de golpe, a 10 req/s se despachan en 600 ÷ 10 = 60 s.

## Diagrama (alto nivel)

# Flujo de arquitectura (alto nivel)

# Flujo de arquitectura (alto nivel)

```mermaid
flowchart TD
    A[Fuente de registros] --> B(Cloud Scheduler / Trigger)
    B --> C[Validador & Normalizador<br/>(Cloud Run / CF)]
    C -->|Auditoría| D[(BigQuery / Storage)]
    C --> E[Cloud Tasks Queue<br/>(rate limit: 10 req/s, retries, TTL)]
    E -->|HTTP Push| F[Worker en Cloud Run]
    F --> G[API Proveedor de llamadas]
    G -->|Respuestas síncronas| F
    F --> H[Pub/Sub DLQ opcional<br/>(errores definitivos > N reintentos)]

    I[Webhook estados proveedor] --> J[Cloud Run Webhook]
    J --> K[(BigQuery métricas/estado)]
    J --> L[Alerting / Monitoring]


## Componentes y políticas clave

- Cloud Tasks: controla `rate limit` (`maxDispatchesPerSecond=10`) y reintentos con backoff exponencial; desacopla picos.
- Cloud Run (worker): idempotente (usa `X-Idempotency-Key` o `call_id`), `timeouts` menores al del proveedor, y `circuit breaker` ante error rate alto.
- Secrets Manager: manejo seguro de credenciales/API keys.
- BigQuery: almacenamiento de métricas y auditoría (intentos, resultados, latencias).
- Pub/Sub DLQ: para registros que fallan definitivamente tras varios reintentos.
- Cloud Monitoring / Alerting: alertas por `p95 latencia`, `tasa de errores`, y `tamaño de cola`.

## Configuración ejemplo (esqueleto)

### Cola (Cloud Tasks)

- `maxDispatchesPerSecond = 10`
- `maxConcurrentDispatches = 50`
- `retryConfig`: backoff exponencial  
  - `minBackoff = 2s`  
  - `maxBackoff = 300s`  
  - `maxAttempts = 10`
- TTL de tareas acorde al SLA (ej: `24h`)

### Worker (Cloud Run)

- `concurrency = 10–20`
- Autoscaling con `max-instances` suficiente (la cola ya limita el RPS).
- `timeouts ≈ p95` del proveedor + margen.
- Idempotencia y deduplicación por `record_id`.
- Observabilidad: logging estructurado + tracing.

