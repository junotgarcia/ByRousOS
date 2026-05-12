-- =============================================================================
-- ByRousOS - Migration 001: Initial Schema
-- =============================================================================
-- Version:      2.0.0
-- Fecha:        2026-05-11
-- Descripcion:  Schema inicial simplificado de ByRousOS - Minimal Viable Infrastructure.
--               Simplificaciones vs v1: triggers reducidos (18->7), ENUMs reducidos (9->4),
--               RLS simplificado (11->7 politicas), os.agent_metrics diferida a migration 002.
-- Ejecutar en:  Supabase SQL Editor (produccion o staging)
-- ADVERTENCIA:  Revision y aprobacion del CEO requerida antes de ejecutar.
-- =============================================================================
--
-- ORDEN DE EJECUCION:
--   1. Schemas
--   2. Tipos ENUM
--   3. os.*   - Core OS Tables
--   4. os.*   - Governance & Audit Tables
--   5. os.*   - Execution Runtime Tables
--   6. os.*   - Observability Tables
--   7. sbr.*  - StyledByRous Pilot Business Tables
--   8. Indices
--   9. Row Level Security (basico minimo)
--  10. Funciones de utilidad (updated_at automatico)
-- =============================================================================


-- =============================================================================
-- 0. SCHEMAS
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS os;
CREATE SCHEMA IF NOT EXISTS sbr;

COMMENT ON SCHEMA os  IS 'ByRousOS - Sistema operativo: agentes, gobierno, ejecucion, observabilidad.';
COMMENT ON SCHEMA sbr IS 'StyledByRous - Modulo piloto de negocio. Replicable con otro prefijo para otras empresas.';


-- =============================================================================
-- 1. TIPOS ENUM
-- =============================================================================

-- Niveles de autonomia segun Gobierno Fase 0, Seccion 5.2
CREATE TYPE os.autonomy_level AS ENUM (
    'A',  -- Rutinario - agente ejecuta solo
    'B',  -- Mediano - agente ejecuta, CEO notificado, reversible 24h
    'C',  -- Alto impacto - debate Proponte/Retador -> CEO aprueba
    'D'   -- Irreversible - bloqueado para agentes, solo CEO
);

-- os.agent_status -> TEXT + CHECK (Fase 1). Convertir a ENUM en Fase 2 con ALTER.

-- Estado de un job o comando en su ciclo de vida
CREATE TYPE os.execution_status AS ENUM (
    'pending',
    'queued',
    'running',
    'completed',
    'failed',
    'rolled_back',
    'cancelled'
);

-- os.risk_level     -> TEXT + CHECK (Fase 1). Convertir a ENUM en Fase 2 con ALTER.
-- os.decision_outcome-> TEXT + CHECK (Fase 1). Convertir a ENUM en Fase 2 con ALTER.
-- os.alert_status   -> TEXT + CHECK (Fase 1). Convertir a ENUM en Fase 2 con ALTER.
-- os.health_status  -> TEXT + CHECK (Fase 1). Convertir a ENUM en Fase 2 con ALTER.

-- Severidad de logs y alertas
CREATE TYPE os.severity AS ENUM (
    'DEBUG',
    'INFO',
    'WARNING',
    'ERROR',
    'CRITICAL'
);

-- os.health_status -> TEXT + CHECK - ver nota arriba.

-- Modo operacional global del sistema
CREATE TYPE os.operational_mode AS ENUM (
    'construction',   -- Fase 0-4: construyendo el OS, sin operaciones comerciales
    'staging',        -- Fase 4: sandbox de pruebas
    'production'      -- Fase 5+: operaciones comerciales reales autorizadas
);


-- =============================================================================
-- 2. FUNCION AUXILIAR: updated_at automatico
-- =============================================================================

CREATE OR REPLACE FUNCTION os.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- =============================================================================
-- GRUPO 1 - CORE OS TABLES
-- Que agentes existen, como estan configurados, que esta corriendo.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- os.agents
-- Registro permanente de todos los agentes del sistema.
-- Un agente es una entidad permanente. Su configuracion vive en agent_configs.
-- -----------------------------------------------------------------------------
CREATE TABLE os.agents (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            TEXT NOT NULL UNIQUE,          -- 'A38', 'A39', 'EXECUTOR_RUNTIME', etc.
    name            TEXT NOT NULL,                 -- 'CTO', 'Ingeniero de Agentes IA', etc.
    area            TEXT NOT NULL,                 -- 'technology', 'operations', 'finance', etc.
    description     TEXT,
    max_autonomy    os.autonomy_level NOT NULL DEFAULT 'A',
    status          TEXT NOT NULL DEFAULT 'conceptual'
                        CHECK (status IN ('conceptual','active','paused','frozen','deprecated')),
    reports_to      UUID REFERENCES os.agents(id), -- jerarquia de agentes
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  os.agents             IS 'Registro permanente de todos los agentes del sistema. No se eliminan - se deprecan.';
COMMENT ON COLUMN os.agents.code        IS 'Codigo unico del agente segun estructura corporativa. Ej: A38, A39, A40.';
COMMENT ON COLUMN os.agents.max_autonomy IS 'Nivel maximo de autonomia que este agente puede ejercer sin escalacion.';
COMMENT ON COLUMN os.agents.status      IS 'conceptual = definido pero no implementado. Solo A38/A39/A40 seran active en Fase 3.';

CREATE TRIGGER agents_updated_at
    BEFORE UPDATE ON os.agents
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();


-- -----------------------------------------------------------------------------
-- os.agent_configs
-- Configuracion activa y versionada de cada agente.
-- Separada de agents para permitir rollback de configuracion.
-- Solo A39 o el CEO pueden insertar nuevas versiones.
-- -----------------------------------------------------------------------------
CREATE TABLE os.agent_configs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id        UUID NOT NULL REFERENCES os.agents(id),
    version         INTEGER NOT NULL DEFAULT 1,
    model_provider  TEXT NOT NULL DEFAULT 'anthropic',     -- 'anthropic', 'openai', 'local'
    model_name      TEXT NOT NULL DEFAULT 'claude-sonnet-4-20250514',
    system_prompt   TEXT NOT NULL,
    max_tokens      INTEGER NOT NULL DEFAULT 4096,
    temperature     NUMERIC(3,2) NOT NULL DEFAULT 0.3,
    tools_enabled   TEXT[] DEFAULT '{}',                   -- nombres de herramientas habilitadas
    context_limit_h INTEGER NOT NULL DEFAULT 72,           -- horas de memoria de contexto
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    activated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    activated_by    TEXT NOT NULL DEFAULT 'system',        -- 'CEO', 'A39', 'system'
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (agent_id, version)
);

COMMENT ON TABLE  os.agent_configs           IS 'Configuracion versionada de agentes. Solo la version con is_active=true esta en uso.';
COMMENT ON COLUMN os.agent_configs.version   IS 'Incrementa con cada cambio de configuracion. Permite rollback a version anterior.';
COMMENT ON COLUMN os.agent_configs.is_active IS 'Solo un registro por agent_id puede tener is_active=TRUE.';
-- Trigger updated_at diferido a Fase 2 (sin agentes activos en Fase 1).


-- -----------------------------------------------------------------------------
-- os.system_config
-- Parametros globales del OS. Una sola fila activa a la vez.
-- -----------------------------------------------------------------------------
CREATE TABLE os.system_config (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operational_mode    os.operational_mode NOT NULL DEFAULT 'construction',
    version             TEXT NOT NULL DEFAULT '0.1.0',
    max_concurrent_jobs INTEGER NOT NULL DEFAULT 10,
    retry_max_attempts  INTEGER NOT NULL DEFAULT 3,
    retry_backoff_base_ms INTEGER NOT NULL DEFAULT 1000,
    degraded_mode_active BOOLEAN NOT NULL DEFAULT FALSE,
    maintenance_mode    BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by          TEXT NOT NULL DEFAULT 'system',
    notes               TEXT
);

COMMENT ON TABLE os.system_config IS 'Parametros globales del OS. Debe existir exactamente una fila. Modificable solo por CEO (nivel D).';

-- Insertar configuracion inicial
INSERT INTO os.system_config (operational_mode, version, notes)
VALUES ('construction', '0.1.0', 'Configuracion inicial - Fase 1. Sin operaciones comerciales activas.');

CREATE TRIGGER system_config_updated_at
    BEFORE UPDATE ON os.system_config
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();


-- -----------------------------------------------------------------------------
-- os.jobs
-- Tareas en ejecucion o en cola. El Execution Core las procesa.
-- -----------------------------------------------------------------------------
CREATE TABLE os.jobs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_type        TEXT NOT NULL,                -- 'agent_task', 'scheduled', 'webhook', etc.
    agent_id        UUID REFERENCES os.agents(id),
    command_id      UUID,                         -- FK a os.commands (se agrega luego con ALTER)
    status          os.execution_status NOT NULL DEFAULT 'pending',
    priority        SMALLINT NOT NULL DEFAULT 5,  -- 1 (mas alta) a 10 (mas baja)
    payload         JSONB NOT NULL DEFAULT '{}',
    retry_count     SMALLINT NOT NULL DEFAULT 0,
    max_retries     SMALLINT NOT NULL DEFAULT 3,
    next_retry_at   TIMESTAMPTZ,
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    error_message   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  os.jobs            IS 'Cola de tareas del sistema. El Job Worker las procesa en orden de prioridad.';
COMMENT ON COLUMN os.jobs.priority   IS '1 = maxima prioridad (CEO/critico). 10 = minima prioridad (batch).';
COMMENT ON COLUMN os.jobs.payload    IS 'Datos de entrada del job. JSONB para flexibilidad entre tipos de tarea.';
-- Trigger updated_at diferido a Fase 2 (Job Worker no existe en Fase 1).


-- -----------------------------------------------------------------------------
-- os.job_results
-- Resultado persistente de cada job. Desacoplado de jobs para no mutar historial.
-- -----------------------------------------------------------------------------
CREATE TABLE os.job_results (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id      UUID NOT NULL REFERENCES os.jobs(id),
    success     BOOLEAN NOT NULL,
    output      JSONB DEFAULT '{}',
    duration_ms INTEGER,
    attempt     SMALLINT NOT NULL DEFAULT 1,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.job_results IS 'Resultados inmutables de jobs. Un job puede tener multiples resultados (reintentos).';


-- =============================================================================
-- GRUPO 2 - GOVERNANCE & AUDIT TABLES
-- Logs inmutables. Nunca se modifican. Append-only por politica.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- os.audit_log
-- Tabla mas critica del sistema. Registro inmutable de toda accion.
-- RLS: solo INSERT. Ni A38 puede hacer UPDATE o DELETE.
-- Base del Rollback Worker: usa state_before para revertir.
-- -----------------------------------------------------------------------------
CREATE TABLE os.audit_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id        UUID REFERENCES os.agents(id),
    agent_code      TEXT NOT NULL,                 -- desnormalizado para legibilidad en auditoria
    action_type     TEXT NOT NULL,                 -- 'INSERT', 'UPDATE', 'DELETE', 'EXECUTE', etc.
    entity_type     TEXT NOT NULL,                 -- tabla o recurso afectado: 'sbr.ventas', 'os.agent_configs'
    entity_id       TEXT,                          -- ID del registro afectado (TEXT para soportar cualquier tipo)
    autonomy_level  os.autonomy_level NOT NULL,
    confidence_score NUMERIC(3,2),                 -- 0.00 a 1.00 - si < 0.7, debio escalar
    risk_level      TEXT NOT NULL DEFAULT 'LOW'
                        CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    state_before    JSONB,                         -- estado anterior - base del rollback
    state_after     JSONB,                         -- estado posterior
    command_id      UUID,                          -- FK a os.commands
    job_id          UUID,                          -- FK a os.jobs
    approved_by     TEXT,                          -- 'CEO', 'A38', 'system', null si nivel A
    approval_ref    UUID,                          -- FK a os.approval_requests si aplica
    notes           TEXT,
    logged_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- Sin updated_at: esta tabla es append-only. Nunca se modifica.
);

COMMENT ON TABLE  os.audit_log              IS 'APPEND-ONLY. Registro inmutable de toda accion del sistema. Base del Rollback Worker. Nunca se modifica ni elimina.';
COMMENT ON COLUMN os.audit_log.state_before IS 'JSON del estado anterior al cambio. El Rollback Worker usa esto para revertir.';
COMMENT ON COLUMN os.audit_log.agent_code   IS 'Desnormalizado intencionalmente: si un agente se depreca, el historial debe seguir siendo legible.';


-- -----------------------------------------------------------------------------
-- os.decisions_log
-- Registro de decisiones de nivel C y D (debate Proponte/Retador -> CEO).
-- Append-only.
-- -----------------------------------------------------------------------------
CREATE TABLE os.decisions_log (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_type       TEXT NOT NULL,             -- 'strategic', 'architecture', 'governance', etc.
    autonomy_level      os.autonomy_level NOT NULL CHECK (autonomy_level IN ('C', 'D')),
    title               TEXT NOT NULL,
    context             TEXT NOT NULL,             -- descripcion del problema / decision
    proposer_agent      TEXT,                      -- agente que propone (puede ser CEO)
    challenger_agent    TEXT,                      -- agente retador (puede ser CEO)
    proposer_argument   TEXT,
    challenger_argument TEXT,
    outcome             TEXT NOT NULL DEFAULT 'pending'
                            CHECK (outcome IN ('approved','rejected','escalated','pending')),
    decided_by          TEXT,                      -- 'CEO' siempre para nivel C/D
    decided_at          TIMESTAMPTZ,
    rationale           TEXT,                      -- por que se tomo esta decision
    audit_log_id        UUID REFERENCES os.audit_log(id),
    logged_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.decisions_log IS 'APPEND-ONLY. Historial de decisiones estrategicas (nivel C y D). Debate Proponte/Retador documentado.';


-- -----------------------------------------------------------------------------
-- os.approval_requests
-- Cola de solicitudes pendientes de aprobacion del CEO.
-- El CEO ve aqui todo lo que requiere su intervencion.
-- -----------------------------------------------------------------------------
CREATE TABLE os.approval_requests (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requesting_agent UUID REFERENCES os.agents(id),
    agent_code      TEXT NOT NULL,
    autonomy_level  os.autonomy_level NOT NULL,
    title           TEXT NOT NULL,
    description     TEXT NOT NULL,
    payload         JSONB NOT NULL DEFAULT '{}',   -- datos completos de la accion a aprobar
    risk_level      TEXT NOT NULL DEFAULT 'MEDIUM'
                        CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    outcome         TEXT NOT NULL DEFAULT 'pending'
                        CHECK (outcome IN ('approved','rejected','escalated','pending')),
    reviewed_by     TEXT,                          -- 'CEO' cuando se resuelve
    reviewed_at     TIMESTAMPTZ,
    review_notes    TEXT,
    expires_at      TIMESTAMPTZ,                   -- null = no expira
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.approval_requests IS 'Cola de aprobaciones pendientes del CEO. Nivel C y D llegan aqui antes de ejecutarse.';

CREATE TRIGGER approval_requests_updated_at
    BEFORE UPDATE ON os.approval_requests
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();


-- -----------------------------------------------------------------------------
-- os.governance_violations
-- Intentos de accion que superaron el nivel de autonomia del agente.
-- Append-only. Nunca se borra. Insumo para auditoria y mejora del sistema.
-- -----------------------------------------------------------------------------
CREATE TABLE os.governance_violations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id        UUID REFERENCES os.agents(id),
    agent_code      TEXT NOT NULL,
    command_id      UUID,
    attempted_action TEXT NOT NULL,
    attempted_autonomy_level os.autonomy_level NOT NULL,
    agent_max_autonomy       os.autonomy_level NOT NULL,
    risk_level      TEXT NOT NULL
                        CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    payload         JSONB DEFAULT '{}',
    blocked_by      TEXT NOT NULL DEFAULT 'governance_middleware',
    notes           TEXT,
    detected_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.governance_violations IS 'APPEND-ONLY. Todo intento de accion que excedio el nivel de autonomia del agente. Nunca se elimina.';


-- =============================================================================
-- GRUPO 3 - EXECUTION RUNTIME TABLES
-- El motor. Eventos -> Comandos -> Ejecucion -> Resultados.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- os.events
-- Todo lo que puede disparar una accion en el sistema.
-- -----------------------------------------------------------------------------
CREATE TABLE os.events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type      TEXT NOT NULL,                 -- 'webhook', 'timer', 'agent_trigger', 'manual', etc.
    source          TEXT NOT NULL,                 -- 'instagram', 'whatsapp', 'internal', 'ceo', etc.
    agent_id        UUID REFERENCES os.agents(id), -- agente que origino el evento (si aplica)
    payload         JSONB NOT NULL DEFAULT '{}',
    status          os.execution_status NOT NULL DEFAULT 'pending',
    command_id      UUID,                          -- FK a os.commands (se agrega con ALTER)
    processed_at    TIMESTAMPTZ,
    error_message   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- Sin updated_at: los eventos no se modifican, se procesan y se registra el resultado.
);

COMMENT ON TABLE os.events IS 'Registro de todo evento recibido por el sistema. Fuente de disparo del Execution Core.';


-- -----------------------------------------------------------------------------
-- os.commands
-- Instrucciones validadas generadas por agentes.
-- Pasan por governance middleware antes de ejecutarse.
-- -----------------------------------------------------------------------------
CREATE TABLE os.commands (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id            UUID REFERENCES os.events(id),
    agent_id            UUID NOT NULL REFERENCES os.agents(id),
    agent_code          TEXT NOT NULL,
    command_type        TEXT NOT NULL,             -- 'read', 'write', 'delete', 'notify', 'escalate', etc.
    target_entity       TEXT NOT NULL,             -- tabla o recurso objetivo: 'sbr.ventas', 'os.agent_configs'
    autonomy_level      os.autonomy_level NOT NULL,
    confidence_score    NUMERIC(3,2) NOT NULL,     -- 0.00 a 1.00
    risk_level          TEXT NOT NULL DEFAULT 'LOW'
                            CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    payload             JSONB NOT NULL DEFAULT '{}',
    governance_passed   BOOLEAN,                   -- null = no evaluado aun
    governance_notes    TEXT,
    approval_request_id UUID REFERENCES os.approval_requests(id),
    status              os.execution_status NOT NULL DEFAULT 'pending',
    audit_log_id        UUID REFERENCES os.audit_log(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  os.commands                    IS 'Instrucciones de agentes. Pasan por governance middleware antes de ejecutarse.';
COMMENT ON COLUMN os.commands.confidence_score   IS 'Si < 0.7 el governance middleware escala automaticamente, independientemente del nivel declarado.';
COMMENT ON COLUMN os.commands.governance_passed  IS 'NULL = no evaluado. TRUE = aprobado. FALSE = bloqueado.';

CREATE TRIGGER commands_updated_at
    BEFORE UPDATE ON os.commands
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();


-- -----------------------------------------------------------------------------
-- os.execution_runs
-- Cada intento de ejecucion de un comando. Un comando puede tener varios
-- (reintentos). El Retry Worker crea nuevas filas, no modifica las existentes.
-- -----------------------------------------------------------------------------
CREATE TABLE os.execution_runs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    command_id      UUID NOT NULL REFERENCES os.commands(id),
    job_id          UUID REFERENCES os.jobs(id),
    attempt_number  SMALLINT NOT NULL DEFAULT 1,
    worker_id       TEXT,                          -- identificador del worker que proceso
    status          os.execution_status NOT NULL DEFAULT 'running',
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,
    duration_ms     INTEGER,
    output          JSONB DEFAULT '{}',
    error_code      TEXT,
    error_message   TEXT,
    audit_log_id    UUID REFERENCES os.audit_log(id)
);

COMMENT ON TABLE  os.execution_runs               IS 'Cada intento de ejecucion de un comando. Append-only: el Retry Worker agrega filas nuevas.';
COMMENT ON COLUMN os.execution_runs.attempt_number IS 'Numero de intento. 1 = primera ejecucion. 2+ = reintento por Retry Worker.';


-- -----------------------------------------------------------------------------
-- os.dead_letter_queue
-- Comandos y mensajes que fallaron todos sus reintentos.
-- Requieren revision manual por A39 o CEO.
-- -----------------------------------------------------------------------------
CREATE TABLE os.dead_letter_queue (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type     TEXT NOT NULL,                 -- 'command', 'job', 'event', etc.
    source_id       UUID NOT NULL,                 -- ID del command/job/event fallido
    agent_code      TEXT,
    failure_reason  TEXT NOT NULL,
    attempts        SMALLINT NOT NULL DEFAULT 0,
    last_error      TEXT,
    payload         JSONB NOT NULL DEFAULT '{}',
    status          TEXT NOT NULL DEFAULT 'pending_review', -- 'pending_review', 'resolved', 'discarded'
    resolved_by     TEXT,
    resolved_at     TIMESTAMPTZ,
    resolution_notes TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.dead_letter_queue IS 'Mensajes que agotaron todos los reintentos. A39 los revisa diariamente segun el Gobierno.';

CREATE TRIGGER dead_letter_queue_updated_at
    BEFORE UPDATE ON os.dead_letter_queue
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();


-- -----------------------------------------------------------------------------
-- os.rollback_log
-- Registro de cada rollback ejecutado por el Rollback Worker.
-- Append-only. Fuente de verdad de reversiones.
-- -----------------------------------------------------------------------------
CREATE TABLE os.rollback_log (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    command_id          UUID NOT NULL REFERENCES os.commands(id),
    audit_log_id        UUID NOT NULL REFERENCES os.audit_log(id), -- state_before usado para revertir
    rolled_back_by      TEXT NOT NULL,             -- 'rollback_worker', 'CEO', 'A38'
    reason              TEXT NOT NULL,
    state_restored      JSONB NOT NULL,            -- copia del state_before que se restauro
    success             BOOLEAN NOT NULL,
    error_message       TEXT,                      -- si success=false
    executed_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.rollback_log IS 'APPEND-ONLY. Registro de cada rollback ejecutado. Fuente de verdad del Rollback Worker.';


-- Agregar FKs cruzadas ahora que ambas tablas existen
ALTER TABLE os.jobs    ADD CONSTRAINT jobs_command_id_fk    FOREIGN KEY (command_id) REFERENCES os.commands(id);
ALTER TABLE os.events  ADD CONSTRAINT events_command_id_fk  FOREIGN KEY (command_id) REFERENCES os.commands(id);


-- =============================================================================
-- GRUPO 4 - OBSERVABILITY TABLES
-- Sin observabilidad, no hay produccion. La capa que hace el sistema visible.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- os.operational_logs
-- Logs tecnicos de ejecucion. Alta velocidad de escritura.
-- Retencion: 30 dias. Purgables (la unica tabla con purga automatica).
-- -----------------------------------------------------------------------------
CREATE TABLE os.operational_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id    UUID REFERENCES os.agents(id),
    agent_code  TEXT,
    component   TEXT NOT NULL,                     -- 'command_worker', 'retry_worker', 'audit_worker', etc.
    severity    os.severity NOT NULL DEFAULT 'INFO',
    message     TEXT NOT NULL,
    context     JSONB DEFAULT '{}',                -- datos adicionales: latencia, IDs relacionados
    command_id  UUID,
    job_id      UUID,
    logged_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- Sin updated_at: los logs no se modifican.
);

COMMENT ON TABLE  os.operational_logs           IS 'Logs tecnicos de ejecucion. Retencion: 30 dias. Son los unicos logs purgables del sistema.';
COMMENT ON COLUMN os.operational_logs.component IS 'Worker o componente que genero el log. Facilita filtrado en el dashboard de observabilidad.';


-- -----------------------------------------------------------------------------
-- os.health_checks
-- Estado de cada componente en cada punto de tiempo.
-- El Observability Worker escribe aqui periodicamente.
-- -----------------------------------------------------------------------------
CREATE TABLE os.health_checks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    component       TEXT NOT NULL,                 -- 'supabase', 'byrous_api', 'agent_A38', 'n8n', etc.
    status          TEXT NOT NULL
                        CHECK (status IN ('healthy','degraded','unhealthy','unknown')),
    latency_ms      INTEGER,
    details         JSONB DEFAULT '{}',            -- info adicional: version, metricas especificas
    error_message   TEXT,
    checked_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.health_checks IS 'Estado de salud de cada componente del sistema. Escrito periodicamente por el Observability Worker.';


-- os.agent_metrics DIFERIDA A MIGRATION 002
-- Requiere Observability Worker activo (Fase 2) para ser util.
-- Sin el worker que la llena, la tabla existe vacia sin proposito.


-- -----------------------------------------------------------------------------
-- os.system_alerts
-- Alertas generadas por el sistema. El CEO ve las CRITICAL aqui.
-- -----------------------------------------------------------------------------
CREATE TABLE os.system_alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type      TEXT NOT NULL,                 -- 'agent_down', 'governance_violation', 'db_error', etc.
    severity        os.severity NOT NULL,
    component       TEXT,
    agent_id        UUID REFERENCES os.agents(id),
    title           TEXT NOT NULL,
    description     TEXT NOT NULL,
    context         JSONB DEFAULT '{}',
    status          TEXT NOT NULL DEFAULT 'open'
                        CHECK (status IN ('open','acknowledged','resolved','suppressed')),
    acknowledged_by TEXT,
    acknowledged_at TIMESTAMPTZ,
    resolved_by     TEXT,
    resolved_at     TIMESTAMPTZ,
    resolution_notes TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE os.system_alerts IS 'Alertas del sistema. CRITICAL y ERROR escalan al CEO inmediatamente segun el Gobierno.';

CREATE TRIGGER system_alerts_updated_at
    BEFORE UPDATE ON os.system_alerts
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();


-- =============================================================================
-- GRUPO 5 - STYLED BY ROUS PILOT BUSINESS TABLES (sbr.*)
-- Modulo de negocio piloto. Demuestra que el OS puede operar una empresa real.
-- El prefijo sbr.* lo separa semanticamente del OS.
-- Una segunda empresa usaria un prefijo diferente - esto es replicable.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- sbr.config
-- Parametros de configuracion de la empresa piloto.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.config (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clave       TEXT NOT NULL UNIQUE,
    valor       TEXT NOT NULL,
    descripcion TEXT,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sbr.config IS 'Parametros de configuracion del modulo StyledByRous. Equivale a la tabla config del ERP SQLite.';

CREATE TRIGGER sbr_config_updated_at
    BEFORE UPDATE ON sbr.config
    FOR EACH ROW EXECUTE FUNCTION os.set_updated_at();

-- Valores iniciales
INSERT INTO sbr.config (clave, valor, descripcion) VALUES
    ('empresa_nombre',    'Styled by Rous',   'Nombre comercial de la empresa'),
    ('moneda_base',       'DOP',              'Moneda base de operacion'),
    ('iva_porcentaje',    '18',               'Porcentaje de ITBIS/IVA'),
    ('instagram_handle',  '@styledbyrous',    'Handle de Instagram principal'),
    ('timezone',          'America/Santo_Domingo', 'Zona horaria de la empresa');


-- -----------------------------------------------------------------------------
-- sbr.monedas
-- Monedas soportadas y tasas de cambio.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.monedas (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo      TEXT NOT NULL UNIQUE,  -- 'DOP', 'USD', 'EUR'
    nombre      TEXT NOT NULL,
    simbolo     TEXT NOT NULL,
    tasa_a_dop  NUMERIC(12,4) NOT NULL DEFAULT 1,
    es_base     BOOLEAN NOT NULL DEFAULT FALSE,
    activa      BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Triggers sbr.monedas -> sbr.gastos_fijos diferidos a Fase 2.
-- Sin operaciones comerciales en Fase 1, los updated_at no son necesarios todavia.

INSERT INTO sbr.monedas (codigo, nombre, simbolo, tasa_a_dop, es_base) VALUES
    ('DOP', 'Peso Dominicano', 'RD$', 1.0000, TRUE),
    ('USD', 'Dolar Americano', '$',   60.0000, FALSE),
    ('EUR', 'Euro',            'EUR', 65.0000, FALSE);


-- -----------------------------------------------------------------------------
-- sbr.proveedores
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.proveedores (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre      TEXT NOT NULL,
    pais        TEXT,
    contacto    TEXT,
    telefono    TEXT,
    email       TEXT,
    notas       TEXT,
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.proveedores diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.clientes
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.clientes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre          TEXT NOT NULL,
    telefono        TEXT,
    instagram       TEXT,
    email           TEXT,
    notas           TEXT,
    credito_limite  NUMERIC(12,2) NOT NULL DEFAULT 0,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.clientes diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.productos
-- Catalogo de productos. La existencia fisica vive en sbr.inventario.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.productos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku             TEXT NOT NULL UNIQUE,          -- formato SBR-000001
    nombre          TEXT NOT NULL,
    descripcion     TEXT,
    categoria       TEXT,
    tallas          TEXT[] DEFAULT '{}',           -- ['XS','S','M','L','XL']
    colores         TEXT[] DEFAULT '{}',
    proveedor_id    UUID REFERENCES sbr.proveedores(id),
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.productos diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.inventario
-- Stock actual por producto y talla. Costo promedio ponderado.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.inventario (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_id         UUID NOT NULL REFERENCES sbr.productos(id),
    talla               TEXT NOT NULL,
    cantidad            INTEGER NOT NULL DEFAULT 0 CHECK (cantidad >= 0),
    costo_promedio_dop  NUMERIC(12,2) NOT NULL DEFAULT 0,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (producto_id, talla)
);

-- Trigger sbr.inventario diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.inventario_entradas
-- Historico de entradas de inventario. Append-only.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.inventario_entradas (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_id     UUID NOT NULL REFERENCES sbr.productos(id),
    talla           TEXT NOT NULL,
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
    costo_unitario_dop NUMERIC(12,2) NOT NULL,
    moneda_origen   TEXT REFERENCES sbr.monedas(codigo),
    costo_unitario_origen NUMERIC(12,2),
    tasa_cambio     NUMERIC(12,4),
    liquidacion_id  UUID,                          -- FK a sbr.liquidaciones
    notas           TEXT,
    entered_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sbr.inventario_entradas IS 'APPEND-ONLY. Historico de entradas al inventario. No se modifican - se hacen ajustes con entradas negativas si aplica.';


-- -----------------------------------------------------------------------------
-- sbr.liquidaciones
-- Importaciones / compras al proveedor.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.liquidaciones (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo          TEXT NOT NULL UNIQUE,          -- 'LIQ-2026-001'
    proveedor_id    UUID REFERENCES sbr.proveedores(id),
    fecha           DATE NOT NULL,
    moneda_compra   TEXT NOT NULL REFERENCES sbr.monedas(codigo),
    tasa_cambio     NUMERIC(12,4) NOT NULL DEFAULT 1,
    total_compra    NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_gastos_dop NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_piezas    INTEGER NOT NULL DEFAULT 0,
    estado          TEXT NOT NULL DEFAULT 'borrador', -- 'borrador', 'confirmada', 'cerrada'
    notas           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.liquidaciones diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.liquidacion_piezas
-- Piezas individuales dentro de una liquidacion.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.liquidacion_piezas (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    liquidacion_id  UUID NOT NULL REFERENCES sbr.liquidaciones(id),
    producto_id     UUID NOT NULL REFERENCES sbr.productos(id),
    talla           TEXT NOT NULL,
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
    costo_unitario  NUMERIC(12,2) NOT NULL,
    costo_flete_prorrateado NUMERIC(12,2) NOT NULL DEFAULT 0,
    costo_total_dop NUMERIC(12,2) NOT NULL DEFAULT 0
);


-- -----------------------------------------------------------------------------
-- sbr.liquidacion_gastos
-- Gastos asociados a una liquidacion (flete, aduanas, etc.).
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.liquidacion_gastos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    liquidacion_id  UUID NOT NULL REFERENCES sbr.liquidaciones(id),
    concepto        TEXT NOT NULL,
    monto_dop       NUMERIC(12,2) NOT NULL,
    moneda_origen   TEXT REFERENCES sbr.monedas(codigo),
    monto_origen    NUMERIC(12,2),
    tasa_cambio     NUMERIC(12,4),
    notas           TEXT
);


-- -----------------------------------------------------------------------------
-- sbr.liquidacion_reembolsos
-- Reembolsos del proveedor aplicables a una liquidacion.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.liquidacion_reembolsos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    liquidacion_id  UUID NOT NULL REFERENCES sbr.liquidaciones(id),
    concepto        TEXT NOT NULL,
    monto_dop       NUMERIC(12,2) NOT NULL,
    fecha           DATE,
    notas           TEXT
);


-- -----------------------------------------------------------------------------
-- sbr.liquidacion_docs
-- Documentos adjuntos a una liquidacion (facturas, B/L, permisos, etc.).
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.liquidacion_docs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    liquidacion_id  UUID NOT NULL REFERENCES sbr.liquidaciones(id),
    nombre          TEXT NOT NULL,
    tipo            TEXT,                          -- 'factura', 'bl', 'permiso', etc.
    url             TEXT,                          -- URL en Supabase Storage
    uploaded_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- -----------------------------------------------------------------------------
-- sbr.ventas
-- Registro de ventas. Descuenta stock automaticamente (a nivel de aplicacion).
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.ventas (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo          TEXT NOT NULL UNIQUE,          -- 'VTA-2026-001'
    cliente_id      UUID REFERENCES sbr.clientes(id),
    fecha           DATE NOT NULL DEFAULT CURRENT_DATE,
    total_dop       NUMERIC(12,2) NOT NULL DEFAULT 0,
    descuento_dop   NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_final_dop NUMERIC(12,2) NOT NULL DEFAULT 0,
    forma_pago      TEXT NOT NULL DEFAULT 'efectivo', -- 'efectivo', 'transferencia', 'credito', 'mixto'
    estado          TEXT NOT NULL DEFAULT 'completada',
    canal           TEXT NOT NULL DEFAULT 'instagram', -- 'instagram', 'presencial', 'whatsapp'
    notas           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.ventas diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.venta_items
-- Lineas de detalle de cada venta.
-- (No existia explicitamente en el ERP SQLite - se agrega por correctitud relacional.)
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.venta_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id        UUID NOT NULL REFERENCES sbr.ventas(id),
    producto_id     UUID NOT NULL REFERENCES sbr.productos(id),
    talla           TEXT NOT NULL,
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario_dop NUMERIC(12,2) NOT NULL,
    costo_unitario_dop  NUMERIC(12,2) NOT NULL DEFAULT 0,
    descuento_dop   NUMERIC(12,2) NOT NULL DEFAULT 0,
    subtotal_dop    NUMERIC(12,2) NOT NULL
);


-- -----------------------------------------------------------------------------
-- sbr.cxc - Cuentas por Cobrar
-- Se genera automaticamente cuando forma_pago = 'credito'.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.cxc (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id        UUID REFERENCES sbr.ventas(id),
    cliente_id      UUID NOT NULL REFERENCES sbr.clientes(id),
    monto_original  NUMERIC(12,2) NOT NULL,
    monto_pendiente NUMERIC(12,2) NOT NULL,
    fecha_vencimiento DATE,
    estado          TEXT NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'parcial', 'pagada', 'vencida'
    notas           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.cxc diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.cxc_pagos - Abonos a Cuentas por Cobrar
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.cxc_pagos (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cxc_id      UUID NOT NULL REFERENCES sbr.cxc(id),
    monto_dop   NUMERIC(12,2) NOT NULL CHECK (monto_dop > 0),
    forma_pago  TEXT NOT NULL,
    fecha       DATE NOT NULL DEFAULT CURRENT_DATE,
    notas       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- -----------------------------------------------------------------------------
-- sbr.cxp - Cuentas por Pagar
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.cxp (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proveedor_id    UUID REFERENCES sbr.proveedores(id),
    liquidacion_id  UUID REFERENCES sbr.liquidaciones(id),
    concepto        TEXT NOT NULL,
    monto_original  NUMERIC(12,2) NOT NULL,
    monto_pendiente NUMERIC(12,2) NOT NULL,
    fecha_vencimiento DATE,
    estado          TEXT NOT NULL DEFAULT 'pendiente',
    notas           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.cxp diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.cxp_pagos - Abonos a Cuentas por Pagar
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.cxp_pagos (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cxp_id      UUID NOT NULL REFERENCES sbr.cxp(id),
    monto_dop   NUMERIC(12,2) NOT NULL CHECK (monto_dop > 0),
    forma_pago  TEXT NOT NULL,
    fecha       DATE NOT NULL DEFAULT CURRENT_DATE,
    notas       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- -----------------------------------------------------------------------------
-- sbr.gastos_fijos
-- Gastos operativos recurrentes (no ligados a una compra o liquidacion).
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.gastos_fijos (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concepto    TEXT NOT NULL,
    monto_dop   NUMERIC(12,2) NOT NULL,
    frecuencia  TEXT NOT NULL DEFAULT 'mensual',   -- 'mensual', 'anual', 'unico'
    categoria   TEXT,
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    proximo_vencimiento DATE,
    notas       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger sbr.gastos_fijos diferido a Fase 2.


-- -----------------------------------------------------------------------------
-- sbr.movimientos
-- Libro mayor simplificado. Registro de todo movimiento financiero.
-- Append-only.
-- -----------------------------------------------------------------------------
CREATE TABLE sbr.movimientos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo            TEXT NOT NULL,                 -- 'ingreso', 'egreso', 'ajuste'
    concepto        TEXT NOT NULL,
    monto_dop       NUMERIC(12,2) NOT NULL,
    referencia_tipo TEXT,                          -- 'venta', 'cxp_pago', 'gasto_fijo', etc.
    referencia_id   UUID,                          -- ID de la entidad origen
    fecha           DATE NOT NULL DEFAULT CURRENT_DATE,
    notas           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sbr.movimientos IS 'APPEND-ONLY. Libro mayor simplificado. Todo movimiento financiero queda registrado aqui.';


-- =============================================================================
-- 8. INDICES
-- =============================================================================

-- OS Core
CREATE INDEX idx_agents_code           ON os.agents(code);
CREATE INDEX idx_agents_status         ON os.agents(status);
CREATE INDEX idx_agent_configs_active  ON os.agent_configs(agent_id) WHERE is_active = TRUE;
CREATE INDEX idx_jobs_status           ON os.jobs(status);
CREATE INDEX idx_jobs_priority         ON os.jobs(priority, created_at) WHERE status = 'pending';
CREATE INDEX idx_jobs_next_retry       ON os.jobs(next_retry_at) WHERE status = 'failed';

-- Governance & Audit
CREATE INDEX idx_audit_log_agent       ON os.audit_log(agent_id, logged_at DESC);
CREATE INDEX idx_audit_log_entity      ON os.audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_logged_at   ON os.audit_log(logged_at DESC);
CREATE INDEX idx_audit_log_command     ON os.audit_log(command_id);
CREATE INDEX idx_approval_requests_pending ON os.approval_requests(outcome) WHERE outcome = 'pending';
CREATE INDEX idx_governance_violations_agent ON os.governance_violations(agent_id, detected_at DESC);

-- Execution Runtime
CREATE INDEX idx_events_status         ON os.events(status, created_at);
CREATE INDEX idx_commands_status       ON os.commands(status);
CREATE INDEX idx_commands_agent        ON os.commands(agent_id, created_at DESC);
CREATE INDEX idx_execution_runs_command ON os.execution_runs(command_id);
CREATE INDEX idx_dlq_status            ON os.dead_letter_queue(status) WHERE status = 'pending_review';

-- Observability
CREATE INDEX idx_operational_logs_severity  ON os.operational_logs(severity, logged_at DESC);
CREATE INDEX idx_operational_logs_component ON os.operational_logs(component, logged_at DESC);
CREATE INDEX idx_health_checks_component    ON os.health_checks(component, checked_at DESC);
CREATE INDEX idx_system_alerts_open         ON os.system_alerts(severity, status) WHERE status = 'open';

-- StyledByRous Business
CREATE INDEX idx_sbr_inventario_producto    ON sbr.inventario(producto_id);
CREATE INDEX idx_sbr_ventas_fecha           ON sbr.ventas(fecha DESC);
CREATE INDEX idx_sbr_ventas_cliente         ON sbr.ventas(cliente_id);
CREATE INDEX idx_sbr_cxc_estado            ON sbr.cxc(estado) WHERE estado IN ('pendiente', 'parcial', 'vencida');
CREATE INDEX idx_sbr_cxp_estado            ON sbr.cxp(estado) WHERE estado IN ('pendiente', 'parcial');
CREATE INDEX idx_sbr_movimientos_fecha      ON sbr.movimientos(fecha DESC);
CREATE INDEX idx_sbr_liquidaciones_estado   ON sbr.liquidaciones(estado);
-- Indice de os.agent_metrics diferido a migration 002 junto con la tabla.


-- =============================================================================
-- 9. ROW LEVEL SECURITY - BASICO MINIMO
-- =============================================================================

-- Habilitar RLS en tablas criticas del OS
ALTER TABLE os.audit_log              ENABLE ROW LEVEL SECURITY;
ALTER TABLE os.governance_violations  ENABLE ROW LEVEL SECURITY;
ALTER TABLE os.rollback_log           ENABLE ROW LEVEL SECURITY;
ALTER TABLE os.decisions_log          ENABLE ROW LEVEL SECURITY;

-- audit_log: solo INSERT (append-only). Nadie puede UPDATE ni DELETE.
CREATE POLICY audit_log_insert_only ON os.audit_log
    FOR INSERT WITH CHECK (TRUE);

CREATE POLICY audit_log_no_update ON os.audit_log
    AS RESTRICTIVE FOR UPDATE USING (FALSE);

CREATE POLICY audit_log_no_delete ON os.audit_log
    AS RESTRICTIVE FOR DELETE USING (FALSE);

-- governance_violations: solo INSERT.
CREATE POLICY governance_violations_insert_only ON os.governance_violations
    FOR INSERT WITH CHECK (TRUE);

CREATE POLICY governance_violations_no_delete ON os.governance_violations
    AS RESTRICTIVE FOR DELETE USING (FALSE);

-- rollback_log: solo INSERT.
CREATE POLICY rollback_log_insert_only ON os.rollback_log
    FOR INSERT WITH CHECK (TRUE);

-- decisions_log: solo INSERT.
CREATE POLICY decisions_log_insert_only ON os.decisions_log
    FOR INSERT WITH CHECK (TRUE);

-- SELECT: controlado por service key en Fase 1.
-- Politicas SELECT por rol de agente se agregan en Fase 3 cuando A38/A39 tengan roles de DB asignados.


-- =============================================================================
-- FIN DE MIGRATION 001 v2.0.0
-- =============================================================================
--
-- RESUMEN DEL SCHEMA (v2 - Minimal Viable Infrastructure):
--
-- SIMPLIFICACIONES vs v1:
--   Triggers:      18 -> 7   (11 diferidos a Fase 2)
--   ENUMs:          9 -> 4   (5 convertidos a TEXT + CHECK)
--   RLS policies:  11 -> 7   (4 SELECT eliminadas)
--   Tablas:        38 -> 37  (os.agent_metrics -> migration 002)
--
-- ENUMs ACTIVOS (4):
--   os.autonomy_level, os.execution_status, os.severity, os.operational_mode
--
-- TRIGGERS ACTIVOS (7):
--   os.agents, os.system_config, os.approval_requests,
--   os.commands, os.dead_letter_queue, os.system_alerts, sbr.config
--
-- TABLAS APPEND-ONLY (nunca se modifican):
--   os.audit_log, os.governance_violations, os.decisions_log,
--   os.rollback_log, os.execution_runs, sbr.inventario_entradas,
--   sbr.movimientos, sbr.cxc_pagos, sbr.cxp_pagos
--
-- NOTA PARA EL CEO:
--   Antes de ejecutar, crear el proyecto Supabase y ejecutar este archivo
--   completo en el SQL Editor. El orden de los bloques importa.
--   Proximo paso: conectar ByRousOS (Next.js) a Supabase via variables
--   de entorno (SUPABASE_URL + SUPABASE_ANON_KEY + SUPABASE_SERVICE_KEY).
-- =============================================================================
