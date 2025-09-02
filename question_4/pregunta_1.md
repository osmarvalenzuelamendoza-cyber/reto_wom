PREGUNTA: Indicar que preguntas realizarías como especialista técnico a las áreas de negocio

## Contexto & SLA

- ¿Cuál es el objetivo de la llamada (cobranza, NPS, retención, confirmaciones)?
- ¿SLA de inicio de llamada desde que se genera el registro? ¿Ventanas horarias por zona horaria y consentimiento?
- ¿Priorización (VIP, morosos, riesgo, campañas)? ¿Reintentos requeridos y con qué cadencia/límites?

## Datos & Calidad

- Campos mínimos por registro (id, teléfono normalizado, país, idioma, campaña, motivo, canal preferido, consentimiento).
- Fuente maestra y unicidad del registro. ¿Cómo definimos idempotencia/dedupe?

## Negocio & Métrica

- ¿Qué es éxito de la llamada? (conectada, atendida, duración, resultado).
- KPIs y tableros (tasa conexión, intentos, tiempos, rechazos, costos).

## Cumplimiento

- Políticas de Do-Not-Call/consentimiento, retención de datos, GDPR/PCI/LOPD.
- ¿Requieren grabación o solo disparar la llamada? ¿Necesidad de auditoría (quién/qué/cuándo)?

## Operación

- Volúmenes máximos y picos (campañas, estacionales).
- ¿Necesitan pausar o estrangular el envío (throttling) en caliente?
