# BYROUS OS

# Documento de Gobierno — Fase 0

**Versión:** v4.2  
**Fecha:** 2026-05-13  
**Commit de referencia:** b7b24fb  
**Estado:** Gobierno constitucional vigente · Fase 1 cerrada · Fase 2 pendiente de apertura formal  
**CONFIDENCIAL**

---

## Advertencia Crítica

El mayor riesgo de este proyecto es construir una corporación simulada en lugar de un sistema verdaderamente operacional.

Un agente que genera texto sin ejecutar acciones persistentes no es un agente operacional: es una interfaz de conversación.

Todo lo definido en este documento existe para garantizar que ByRousOS ejecuta acciones reales con efectos verificables, auditables y reversibles.

**Restricción operacional absoluta:** ByRousOS no está diseñado para operar la empresa real en esta fase. La fase actual es construcción del sistema operativo. No hay ventas reales, clientes reales, Instagram, WhatsApp, DMs, e-commerce, gastos reales ni operaciones comerciales de ningún tipo hasta que se cumplan los Criterios de Preparación Operacional definidos en este documento.

---

## 0. Principios de Operación IA-Nativa

Estos principios son la base filosófica de ByRousOS. Toda decisión de arquitectura, diseño e implementación debe ser consistente con ellos.

| Principio | Definición |
|---|---|
| Estado sobre conversación | El estado persistente en base de datos es la fuente de verdad. Las conversaciones son efímeras; el estado es permanente. |
| Ejecución sobre generación | El objetivo de un agente es ejecutar acciones que cambian el estado del sistema, no generar texto. |
| Gobierno antes de autonomía | Ningún agente opera sin reglas claras de autonomía, límites y escalación. |
| Logs antes de acciones | Toda acción se registra antes de ejecutarse. Si no puede registrarse, no se ejecuta. |
| Reversible por diseño | Toda acción de nivel A y B debe poder revertirse. Las acciones irreversibles son exclusivas del CEO. |
| Independencia de proveedor | ByRousOS nunca depende de un único proveedor de IA. La capa de modelos es intercambiable. |
| Los humanos aprueban lo irreversible | El CEO tiene autoridad absoluta y puede pausar, congelar o anular cualquier agente o proceso en cualquier momento. |
| Estado persistente como fuente de verdad | Supabase/PostgreSQL es la fuente de verdad operacional. Los agentes consultan y actualizan la base de datos; no tienen estado propio. |
| Agentes dentro de límites gobernados | Ningún agente puede expandir sus propios límites de autonomía. Solo el CEO puede modificar niveles de autonomía. |
| Observabilidad obligatoria | Todo componente expone métricas, logs y estado. Un componente no observable no está en producción. |
| Seguridad antes de autonomía | Ningún agente real ni autonomía operacional puede activarse sin controles mínimos de ciberseguridad y permisos runtime revisados. |

---

## 1. Separación: Construcción del Sistema vs Operación Comercial

Esta es la distinción más importante del documento. Son dos fases completamente separadas con criterios de transición explícitos.

| Dimensión | Fase de Construcción | Fase de Operación Comercial |
|---|---|---|
| Objetivo | Construir el sistema operativo | Operar la empresa real |
| Agentes activos | Conceptuales o fundadores según fase autorizada | Agentes especializados según plan aprobado |
| Canales externos | Ninguno — completamente aislado | Instagram, WhatsApp, APIs externas |
| Clientes reales | Prohibido | Autorizado tras readiness |
| Transacciones | Datos de prueba en sandbox | Ventas, cobros, pagos reales |
| Base de datos | Supabase/PostgreSQL para infraestructura y sandbox | Supabase producción para operación real aprobada |
| Criterio de éxito | Execution Core estable, observable y auditable | KPIs de negocio cumplidos bajo gobierno |

---

## 2. Criterios de Preparación Operacional — Operational Readiness Gate

La empresa real solo empieza a operar cuando ByRousOS demuestra cumplimiento verificable de todos los criterios siguientes.

No hay excepciones ni atajos.

### 2.1 Criterios Técnicos Obligatorios

| Criterio | Descripción | Verificado por |
|---|---|---|
| Estado persistente estable | La base de datos mantiene consistencia bajo carga y concurrencia. Cero corrupciones en 72h de prueba. | A38 + A40 |
| Execution runtime funcional | Los agentes ejecutan comandos reales que modifican el estado de Supabase/PostgreSQL con éxito verificable. | A39 |
| Auditoría completa | Toda acción genera log de auditoría inmutable con contexto completo. Cobertura 100%. | A38 |
| Rollback básico funcional | Las acciones de nivel A y B pueden revertirse correctamente en staging. Pruebas documentadas. | A39 |
| Manejo de errores activo | El sistema maneja timeouts, fallos parciales y errores de proveedor sin corrupción de estado. | A38 |
| Retries implementados | Los reintentos automáticos funcionan según política definida. Dead-letter queue activa cuando aplique. | A40 |
| Governance enforcement | Los niveles de autonomía A/B/C/D se cumplen sin excepciones. Pruebas con casos límite. | A38 |
| Trazabilidad completa | Cualquier acción puede rastrearse desde el trigger hasta el resultado final en audit_log. | A38 |
| Control operacional interno | El orquestador puede pausar, reanudar y abortar agentes en tiempo real. | A39 |
| Estabilidad de agentes fundadores | A38, A39 y A40 operan establemente por mínimo 72 horas sin intervención humana. | CEO |
| Ciberseguridad mínima | Permisos runtime, secretos, APIs, roles de base de datos y exposición de herramientas revisados antes de autonomía. | ChatES + CEO |

### 2.2 Criterios de Sandbox Previos a Producción

- Mínimo 7 días de operación en sandbox con datos simulados.
- Cero fallos críticos no recuperados durante el período de sandbox.
- Al menos 3 ciclos completos de rollback exitosos documentados.
- Revisión y aprobación del CEO del reporte de readiness.

El sandbox no es opcional. Es el paso que separa un sistema que parece funcionar de un sistema que realmente funciona bajo condiciones reales.

---

## 3. Qué es ByRousOS

ByRousOS no es la inteligencia artificial.

ByRousOS es el sistema operativo donde vive, opera y es gobernada la inteligencia artificial.

ByRousOS existe para convertir intención, comandos y decisiones gobernadas en acciones persistentes, auditables y recuperables.

---

## 4. Núcleo de Ejecución — Execution Core

El Execution Core es el componente más crítico de ByRousOS.

Es lo que convierte instrucciones de agentes o comandos autorizados en acciones reales y persistentes.

Todo comando pasa por governance middleware antes de ejecutarse:

1. verificar permisos,
2. clasificar nivel de autonomía,
3. verificar confidence_score cuando aplique,
4. confirmar audit_log,
5. ejecutar,
6. registrar resultado,
7. manejar error, rollback o escalación.

Infraestructura conectada no equivale a runtime operativo.

Un endpoint funcionando no significa que el sistema tenga autonomía ni Execution Core completo.

---

## 5. Jerarquía de Autoridad y Niveles de Autonomía

| Nivel | Tipo | Acción del sistema |
|---|---|---|
| A — Rutinario | Operación diaria predecible | Agente ejecuta. Log operacional generado automáticamente. |
| B — Mediano | Decisión con impacto moderado | Agente ejecuta. CEO notificado. Reversible en 24h. |
| C — Alto impacto | Decisión estratégica o de riesgo | Debate Proponente vs Retador. CEO aprueba o rechaza. |
| D — Irreversible | Acción que no se puede deshacer | Bloqueado para agentes. CEO ejecuta personalmente. |

Regla permanente:

- Ningún agente puede modificar su propio nivel de autonomía.
- Ningún sistema puede expandir autonomía sin aprobación CEO.
- Ninguna operación comercial real puede ejecutarse antes del Operational Readiness Gate.

---

## 6. Arquitectura de Resiliencia y Recuperación

El sistema asume que los agentes, modelos y componentes externos fallarán.

La resiliencia es un requisito empresarial, no una característica opcional.

Mecanismos requeridos:

- retry con backoff exponencial,
- dead-letter queue cuando aplique,
- rollback automático o manual según nivel,
- modo degradado,
- failover de proveedor IA,
- trazabilidad de error,
- registro previo a ejecución,
- alertas de estado operacional.

---

## 7. Concurrencia y Protección de Estado

Mecanismos requeridos:

- optimistic locking,
- serialización de escrituras por entidad,
- lock temporal con expiración,
- transacciones atómicas multi-tabla cuando aplique,
- prioridad CEO > C-Suite > agentes operativos,
- prevención de mutaciones no autorizadas sobre logs de auditoría.

---

## 8. Arquitectura de Memoria

| Tipo | Descripción | Dónde vive | Expiración |
|---|---|---|---|
| Memoria de trabajo | Contexto de la tarea en ejecución | Prompt del agente / sesión | Al finalizar la sesión |
| Memoria operacional | Estado actual del negocio y del sistema | Supabase/PostgreSQL — tablas operacionales | Sin expiración. Se actualiza. |
| Memoria histórica | Decisiones pasadas y logs de auditoría | `os.audit_log` y documentos oficiales | Permanente. Append-only. |
| Memoria de agente | Instrucciones y límites de cada agente | Configuración ByRousOS | Actualizable solo por autoridad aprobada |
| Memoria de contexto | Historial reciente relevante para la tarea | Buffer temporal | 72 horas máximo o política aprobada |

---

## 9. Sistema de Logs

### Logs Operacionales

Uso:

- monitoreo en tiempo real,
- debugging,
- diagnóstico de operación,
- observabilidad diaria.

Retención:

- limitada,
- purgable,
- no constitucional.

### Logs de Auditoría

Uso:

- gobierno,
- cumplimiento,
- trazabilidad,
- reconstrucción de decisiones,
- accountability.

Reglas:

- permanentes,
- append-only,
- nunca se modifican,
- nunca se eliminan,
- protegidos a nivel base de datos.

---

## 10. Agentes Fundadores — Estado Inicial

| Agente | Misión en fase de construcción |
|---|---|
| A38 — CTO | Supervisa la arquitectura tecnológica. Toma decisiones de infraestructura bajo gobierno. Reporta directamente al CEO. |
| A39 — Ingeniero de Agentes IA | Construye, configura, prueba y activa agentes. Gestiona el ciclo de vida del sistema de agentes. |
| A40 — Agente de Integraciones | Conecta Supabase, n8n y APIs cuando sea autorizado. Garantiza flujo correcto de datos entre componentes. |
| Executor Runtime Genérico | Motor de ejecución base que procesa comandos antes de que agentes especializados estén activos. |

Regla:

Los agentes fundadores pueden estar definidos conceptualmente antes de estar activos como runtime real.

Definir un agente no equivale a activarlo.

---

## 11. Cybersecurity Governance Capability

ByRousOS requiere una capacidad formal de ciberseguridad antes de agentes reales, autonomía operacional o integraciones externas.

Esta capacidad no activa agentes por sí misma. Es una función de gobierno obligatoria para reducir riesgo antes de expansión.

Responsabilidades mínimas:

- threat modeling,
- secrets management,
- runtime permissions,
- PostgreSQL/Supabase role hardening,
- RLS / GRANT / REVOKE validation,
- API security,
- prompt injection defense,
- agent permission audits,
- incident response,
- revisión previa a autonomía real.

Regla:

No se activa autonomía operacional real sin revisión de ciberseguridad mínima.

---

## 12. Command Handoff Layer — Dirección Futura

El Command Handoff Layer es una capacidad futura para reducir copy/paste entre chats sin crear autonomía directa.

Dirección objetivo:

ChatES → command queue gobernada → CEO aprueba → ChatOP ejecuta → audit_log registra.

Reglas:

- No es ejecución autónoma libre.
- No reemplaza aprobación CEO.
- No conecta agentes reales por sí mismo.
- Debe registrar comandos, aprobación, ejecución y resultado.
- Debe respetar niveles A/B/C/D.

---

## 13. Model Provider Layer — Dirección Futura

ByRousOS debe mantener independencia de proveedor.

La capa de modelos debe ser intercambiable:

- OpenAI,
- Anthropic,
- otros proveedores futuros.

Regla:

ByRousOS orquesta. Los modelos solo proveen inteligencia.

OpenAI API, Anthropic API u otros proveedores no deben convertirse en orquestadores principales del sistema.

No integrar APIs de modelos hasta que exista una capa provider-agnostic y controles de gobierno adecuados.

---

## 14. Document Governance Model

Modelo oficial de gobierno documental de ByRousOS.

Define ownership, validación, aprobación y publicación técnica para cada documento oficial del sistema.

### 14.1 Principios del Gobierno Documental

- GitHub es la única fuente oficial de verdad para documentos oficiales.
- Project Files son capa de continuidad contextual, no autoridad documental.
- Un documento en Project Files sin commit en GitHub no es oficial.
- Un documento generado en chat o sandbox no existe oficialmente hasta estar en repo real, commiteado y pusheado.
- Los documentos estratégicos no son redactados por ChatOP por iniciativa propia.
- ChatOP puede publicar técnicamente contenido aprobado.

### 14.2 Roles Documentales

| Rol | Definición |
|---|---|
| Owner | Responsable primario del contenido y mantenimiento conceptual del documento. |
| Strategic Validator | Valida coherencia estratégica, arquitectura, gobierno, fases y riesgos. |
| Operational Validator | Valida realidad operativa: commits, endpoints, repo, deploy, consistencia con CONTROL_CENTER y ausencia de declaraciones no ejecutadas. |
| Approval Authority | Autoridad que aprueba el cambio oficial. |
| Technical Publisher | Aplica el cambio en filesystem real, Git, commit y push. |

### 14.3 Tabla de Ownership y Autoridad

| Documento | Owner | Strategic Validator | Operational Validator | Approval Authority | Technical Publisher | Authority |
|---|---|---|---|---|---|---|
| CONTROL_CENTER | ChatOP | ChatES | ChatOP | CEO | ChatOP | Operational |
| CURRENT_SYSTEM_STATE | ChatES | ChatES | ChatOP | CEO | ChatOP | Strategic |
| Plan Maestro | ChatES | ChatES / CEO | ChatOP | CEO | ChatOP | Strategic |
| Gobierno_Fase0 | CEO · Maintainer: ChatES | ChatES | ChatOP | CEO | ChatOP | Constitutional |
| TOOLS_AND_ENVIRONMENT | ChatOP | ChatES | ChatOP | CEO | ChatOP | Operational |

### 14.4 Interpretación de Gobierno_Fase0

El CEO es Owner constitucional de Gobierno_Fase0.

Eso no significa que el CEO deba editar manualmente el documento.

Interpretación correcta:

- CEO aprueba cambios constitucionales.
- ChatES redacta/mantiene bajo autoridad del CEO.
- ChatOP valida realidad operativa.
- ChatOP publica técnicamente si el texto fue aprobado.

### 14.5 Separación Correcta de Roles

ChatES valida:

- estrategia,
- arquitectura,
- gobierno,
- fases,
- riesgos,
- coherencia constitucional.

ChatOP valida:

- commits reales,
- endpoints reales,
- repo real,
- deploy real,
- consistencia con CONTROL_CENTER,
- que no se declare algo no ejecutado,
- que no se abra una fase sin aprobación CEO.

CEO aprueba:

- cierres de fase,
- apertura de fases,
- cambios constitucionales,
- expansión de autonomía,
- aceptación de riesgos mayores.

### 14.6 Fuentes de Verdad

| Fuente | Autoridad |
|---|---|
| GitHub | Fuente oficial de verdad documental y técnica. |
| Project Files | Continuidad contextual para chats. No es autoridad oficial. |
| Chat outputs | Borradores hasta que se publiquen en GitHub. |
| Sandbox | Temporal. No oficial. |
| Filesystem real sin commit | No oficial. |
| Commit local sin push | No oficial. |

### 14.7 Reglas de Modificación

- Solo el Owner o maintainer autorizado redacta cambios de contenido.
- Validators recomiendan cambios, pero no editan directamente documentos ajenos sin autorización.
- Ningún documento oficial puede ser modificado simultáneamente por múltiples instancias de chat.
- Todo cambio oficial requiere commit/push en GitHub.
- Documentos deprecated deben marcarse explícitamente como DEPRECATED antes de eliminación.
- Cambios de nivel C o D en documentos constitucionales requieren aprobación explícita del CEO.
- Fase 2 no se abre automáticamente por cierre de Fase 1.

### 14.8 Versionado Documental

Formato vigente:

`vN.N · YYYY-MM-DD · commitHash`

Ejemplo:

`v4.2 · 2026-05-13 · bdba032`

El commit hash de GitHub es la trazabilidad temporal oficial.

Formato deprecado:

- `vDD.MM.YY-HHam/pm`
- nombres `_final`, `_fixed`, `_v2` para archivos oficiales en repo real

### 14.9 Document Authority Flow

CEO → Governance docs → Strategic state → Operational control.

Orden de autoridad:

1. Gobierno_Fase0.
2. CURRENT_SYSTEM_STATE.
3. Plan Maestro.
4. CONTROL_CENTER.
5. TOOLS_AND_ENVIRONMENT.

Ningún documento de menor autoridad puede contradecir uno de mayor autoridad sin aprobación del CEO y actualización del documento superior.

---

## 15. Guided Tool-Opening Protocol

ChatOP no debe asumir que el CEO tiene abiertas las herramientas necesarias.

Antes de cualquier tarea que requiera herramientas externas, ChatOP debe indicar:

1. qué aplicación abrir,
2. qué sitio, pantalla o proyecto seleccionar,
3. qué credencial o secreto no compartir,
4. qué botón o sección buscar,
5. qué no tocar,
6. cuándo detenerse y confirmar.

Aplica a:

- VS Code Tunnel,
- PowerShell / terminal,
- GitHub,
- Vercel,
- Supabase,
- navegador,
- Project Files,
- repo local,
- reemplazo de documentos,
- validaciones,
- deploy.

Regla:

No avanzar a comandos hasta que el CEO confirme que está en la pantalla correcta.

Si VS Code Tunnel falla, cambiar a PowerShell local guiado.

---

## 16. Resumen Ejecutivo — Para el CEO

### ¿En qué fase estamos?

ByRousOS está en fase de construcción del sistema operativo.

Fase 0 está cerrada.

Fase 1 está cerrada formalmente.

Fase 2 está pendiente de apertura formal.

No hay operaciones comerciales activas, clientes reales ni canales externos conectados.

### ¿Cuándo empieza la empresa a operar realmente?

Cuando el sistema pase el Operational Readiness Gate.

Eso requiere criterios técnicos verificables, sandbox, auditoría, rollback, estabilidad, seguridad y aprobación CEO.

### ¿Qué aprueba este documento?

- La IA es intercambiable.
- ByRousOS orquesta; los modelos no gobiernan.
- Construcción y operación comercial son fases separadas.
- Ninguna operación comercial hasta readiness.
- Todo lo oficial vive en GitHub.
- Project Files son continuidad, no autoridad.
- El CEO es autoridad constitucional.
- ChatES mantiene estrategia bajo autoridad CEO.
- ChatOP ejecuta publicación técnica y valida realidad operativa.
- Ciberseguridad es capacidad obligatoria antes de autonomía.
- Fase 2 no se abre automáticamente.

---

## 17. Changelog

| Versión | Fecha | Commit | Cambio |
|---|---|---|---|
| v1.0 | Mayo 2026 | — | Versión inicial — arquitectura cognitiva y gobierno |
| v2.0 | Mayo 2026 | — | Criterios de Operational Readiness Gate añadidos |
| v3.0 | Mayo 2026 | — | Resumen ejecutivo para CEO · Separación construcción/operación explícita |
| v4.0 | 2026-05-12 | — | Sección Document Governance Model añadida · Ownership table · Reglas de modificación · Authority flow · GitHub como fuente de verdad |
| v4.2 | 2026-05-13 | 7b24fb | Versión Markdown oficial para repo · Document Governance Model refinado · versionado actualizado · cybersecurity capability · command handoff layer · model provider layer · guided tool-opening protocol |

---

*ByRousOS · Documento de Gobierno Fase 0 · v4.2 · 2026-05-13 · Confidencial*

