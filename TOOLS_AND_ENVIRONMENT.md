# TOOLS AND ENVIRONMENT — ByRousOS
**ChatOperador — Awareness Operacional Permanente**  
**Versión:** v12.05.26-4pm  
**Fecha:** 2026-05-12  
**Estado:** 🔴 LECTURA OBLIGATORIA al inicio de cada sesión  

---

## ⚠ Advertencia Crítica

> Nada es oficial hasta que existe en el filesystem real, está en Git real, y está pusheado a GitHub.  
> Un archivo creado en el sandbox de chat NO EXISTE para el proyecto.  
> Un commit sin remote NO EXISTE para el proyecto.  
> Reportar algo como "hecho" sin persistencia real verificada es un error de gobierno.

---

## 1. Herramientas Disponibles para ChatOperador

### 1.1 Sandbox de Ejecución (`bash_tool`)

| Atributo | Valor |
|----------|-------|
| Qué es | Contenedor Linux efímero dentro del entorno de Claude.ai |
| Filesystem | `/home/claude/` — temporal, desaparece al cerrar sesión |
| Git | Puede crear repos locales, hacer commits — pero SIN remote a GitHub |
| Red | Acceso a internet deshabilitado en este entorno |
| Persistencia | ❌ NINGUNA — todo se pierde al terminar la sesión |
| Uso correcto | Generar y validar contenido, verificar sintaxis, preparar archivos para entrega |
| Uso incorrecto | Reportar commits como oficiales, asumir que archivos persisten |

### 1.2 Project Files (`/mnt/project/`)

| Atributo | Valor |
|----------|-------|
| Qué es | Archivos que el CEO sube manualmente al Project de Claude |
| Acceso | Read-only — ChatOperador puede leer, NO escribir |
| Persistencia | ✅ Persiste entre sesiones — es la fuente de verdad de contexto |
| Path | `/mnt/project/` |
| Uso correcto | Leer contexto maestro, gobierno, plan maestro al inicio de sesión |
| Actualizar | Solo el CEO puede agregar/reemplazar archivos del Project |

### 1.3 Outputs Descargables (`/mnt/user-data/outputs/`)

| Atributo | Valor |
|----------|-------|
| Qué es | Archivos que Claude genera y el CEO puede descargar desde el chat |
| Acceso | ChatOperador puede escribir aquí |
| Persistencia | ⚠ Solo mientras dura la sesión — el CEO debe descargarlos y guardarlos |
| Uso correcto | Entregar archivos al CEO para que los lleve al repo real |
| Uso incorrecto | Asumir que persisten o que equivalen a estar en GitHub |

### 1.4 Claude Code (en terminal del CEO)

| Atributo | Valor |
|----------|-------|
| Qué es | Instancia de Claude ejecutando en la terminal real del CEO |
| Filesystem | Acceso real al disco local de la máquina del CEO |
| Git | Acceso real — puede hacer commit y push a GitHub |
| Persistencia | ✅ Real — lo que Claude Code hace persiste en el repo |
| Conexión con este chat | ❌ No directa — el CEO es el puente entre chat y Claude Code |
| Uso correcto | Ejecutar archivos que ChatOperador genera en el chat |

### 1.5 Terminal / CMD (en máquina del CEO)

| Atributo | Valor |
|----------|-------|
| Qué es | Terminal real del CEO — Windows CMD, PowerShell o Git Bash |
| Acceso desde este chat | ❌ Ninguno — ChatOperador NO puede ejecutar comandos aquí |
| Git | Acceso real al repo local y a GitHub remote |
| Uso correcto | El CEO copia y ejecuta comandos que ChatOperador proporciona |

### 1.6 GitHub (`junotgarcia/ByRousOS` y otros repos)

| Atributo | Valor |
|----------|-------|
| Acceso desde este chat | ❌ Ninguno — ChatOperador no puede hacer push, pull ni leer repos |
| Acceso real | Solo vía terminal del CEO, Claude Code, o VS Code Tunnel |
| Fuente de verdad | ✅ GitHub es la única fuente de verdad de persistencia de código |
| Verificación | El CEO confirma commit hash en GitHub → ChatOperador lo registra |
| Último commit oficial | `76efb42` — `feat(observability): add operational logger, audit writer, request middleware and observability endpoint -- Phase 1 Step 4` |

### 1.7 Chrome / Browser (Claude in Chrome)

| Atributo | Valor |
|----------|-------|
| Qué es | Extensión de Claude que controla el navegador del CEO |
| Estado actual | ✅ Operacional — confirmado 2026-05-12 |
| Browser activo | Edge (Windows) · deviceId `fc7f0c64` |
| Supabase | ✅ Navegable y operable — dashboard, SQL Editor accesibles |
| Capacidad verificada | Navegación, screenshots, ejecución de queries de verificación |
| Limitación 1 | Inestabilidad parcial con Monaco Editor (SQL Editor de Supabase) — tabs_context_mcp funciona pero interacción pesada puede degradarse |
| Limitación 2 | Acciones pesadas (screenshot + click secuencial) pueden causar timeout — reintentar o simplificar la secuencia |
| Limitación 3 | No introduce credenciales ni ejecuta acciones irreversibles — requiere confirmación del CEO |
| Limitación 4 | URI schemes custom (`vscode://`, `file://`) bloqueados por proxy de red |
| Uso correcto | Verificación de estado, navegación guiada, queries de lectura, asistencia paso a paso, acceso a VS Code Tunnel |

### 1.8 VS Code Tunnel — `byrousos`

| Atributo | Valor |
|----------|-------|
| Qué es | Acceso remoto al VS Code desktop del CEO vía browser — filesystem real + terminal real + git real |
| URL de acceso | `https://vscode.dev/tunnel/byrousos` |
| Activación | CEO ejecuta `code tunnel --name byrousos` en su terminal local |
| Filesystem | ✅ Acceso real al disco local del CEO — repo en `C:\Users\junot\Documents\ByRousOS` |
| Terminal | ✅ PowerShell real — puede ejecutar git, npm, scripts |
| Git | ✅ Acceso real — commit y push a GitHub verificados |
| Persistencia | ✅ Real — lo que se ejecuta aquí persiste en el repo |
| Estado | ✅ Operacional — confirmado 2026-05-12 · usado para integración real del Paso 4 |
| Sintaxis terminal | PowerShell — usar `;` como separador, NO `&&` |
| Limitación 1 | Timeout de extensión Chrome bajo operación pesada — reconectar con `tabs_context_mcp` |
| Limitación 2 | Modales de Copilot/GitHub AI pueden bloquear la vista — cerrar antes de operar |
| Limitación 3 | `localhost:3000` del dev server NO es accesible via tunnel — usar IP de red o Vercel |
| Limitación 4 | `Invoke-WebRequest` desde terminal del tunnel apunta al servidor remoto, no a la máquina local |
| Uso correcto | Integración real de archivos, commits reales, git push, verificación de estado del repo |
| Uso incorrecto | Asumir que `localhost` del tunnel = `localhost` del CEO |

---

## 2. Diferencia Entre Entornos

```
┌─────────────────────────────────────────────────────────────┐
│                    ENTORNOS DE TRABAJO                       │
├─────────────────┬───────────────────────────────────────────┤
│ ENTORNO         │ CARACTERÍSTICAS                           │
├─────────────────┼───────────────────────────────────────────┤
│ Sandbox de chat │ • /home/claude/ en contenedor efímero     │
│ (bash_tool)     │ • Sin remote Git                          │
│                 │ • Sin red real                            │
│                 │ • Desaparece al cerrar sesión             │
│                 │ • ❌ NO persiste                          │
├─────────────────┼───────────────────────────────────────────┤
│ Project Files   │ • /mnt/project/ — read-only               │
│                 │ • Subidos manualmente por el CEO          │
│                 │ • ✅ Persiste entre sesiones              │
│                 │ • Fuente de contexto — NO de código       │
├─────────────────┼───────────────────────────────────────────┤
│ Outputs         │ • /mnt/user-data/outputs/                 │
│                 │ • ChatOperador escribe aquí               │
│                 │ • CEO descarga desde el chat              │
│                 │ • ⚠ Solo persiste si el CEO descarga      │
├─────────────────┼───────────────────────────────────────────┤
│ VS Code Tunnel  │ • https://vscode.dev/tunnel/byrousos      │
│ (NUEVO)         │ • Filesystem real del CEO                 │
│                 │ • Terminal PowerShell real                │
│                 │ • Git real con remote a GitHub            │
│                 │ • ✅ Persiste — es la realidad            │
│                 │ • Accesible via Claude in Chrome          │
├─────────────────┼───────────────────────────────────────────┤
│ Filesystem real │ • Disco local del CEO                     │
│ (CEO + Claude   │ • Git con remote a GitHub                 │
│  Code)          │ • ✅ Persiste — es la realidad            │
│                 │ • ÚNICA fuente de verdad operacional      │
├─────────────────┼───────────────────────────────────────────┤
│ GitHub          │ • Repositorios remotos reales             │
│                 │ • ✅ Persiste — es el estado oficial      │
│                 │ • Solo accesible por terminal/Claude Code │
│                 │   o VS Code Tunnel                        │
└─────────────────┴───────────────────────────────────────────┘
```

---

## 3. VS Code Tunnel — Workflow Operacional

### 3.1 Activación del Tunnel

El CEO ejecuta en su terminal local (una sola vez por sesión):

```powershell
code tunnel --name byrousos
```

Una vez activo, ChatOperador accede via Claude in Chrome navegando a:

```
https://vscode.dev/tunnel/byrousos
```

### 3.2 Verificación Obligatoria al Conectar

Antes de ejecutar cualquier acción real, ChatOperador ejecuta esta secuencia en la terminal del tunnel:

```powershell
# 1. Confirmar ubicación real
cd C:\Users\junot\Documents\ByRousOS
pwd

# 2. Verificar remote Git
git remote -v

# 3. Verificar estado del repo
git status

# 4. Verificar último commit
git log --oneline -3
```

### 3.3 Criterios de Confirmación del Tunnel

| Verificación | Resultado esperado | Si falla |
|---|---|---|
| `pwd` | `C:\Users\junot\Documents\ByRousOS` | Detener — no estás en el repo correcto |
| `git remote -v` | URL de GitHub visible | Detener — repo sin remote no es oficial |
| `git status` | Rama activa, sin errores inesperados | Investigar antes de continuar |
| `git log` | Commits coinciden con CONTROL_CENTER | Investigar discrepancia |

### 3.4 Sintaxis PowerShell — Reglas Críticas

| Bash (incorrecto en PS) | PowerShell (correcto) |
|---|---|
| `cmd1 && cmd2` | `cmd1; cmd2` |
| `rm archivo` | `Remove-Item archivo` |
| `mkdir -p a/b/c` | `New-Item -ItemType Directory -Force a/b/c` |
| `cat archivo` | `Get-Content archivo` |
| `echo "texto" > archivo` | `"texto" \| Set-Content archivo` |
| Heredoc `<< 'EOF'` | `@'...'@ \| Set-Content archivo` |

### 3.5 Limitación Conocida — localhost

El dev server (`npm run dev`) corre en `localhost:3000` de la **máquina del CEO**, no del servidor del tunnel. Para validar endpoints del dev server:

- ✅ El CEO abre `http://localhost:3000/api/...` en su browser local
- ❌ `Invoke-WebRequest http://localhost:3000/...` desde la terminal del tunnel **no funciona**
- ✅ Para acceso externo: usar la URL de Vercel una vez deployado

---

## 4. Cómo Verificar Conectividad Real Antes de Ejecutar

Antes de cualquier tarea que implique Git o persistencia, ejecutar esta verificación:

### 4.1 Comandos de verificación (en terminal real del CEO, Claude Code, o VS Code Tunnel):

```bash
# 1. ¿Dónde estoy?
pwd
# Esperado: C:\Users\junot\Documents\ByRousOS

# 2. ¿Tengo remote configurado?
git remote -v
# Esperado: origin  https://github.com/junotgarcia/ByRousOS.git (fetch/push)

# 3. ¿En qué estado está el repo?
git status
# Esperado: rama limpia o con cambios pendientes — nunca "no remote"

# 4. ¿En qué rama estoy?
git branch
# Esperado: * main

# 5. ¿Cuál es el último commit real?
git log --oneline -5
# Esperado: commits que coincidan con los registrados en CONTROL_CENTER.md
```

### 4.2 Criterios de confirmación:

| Verificación | Resultado esperado | Si falla |
|---|---|---|
| `pwd` | Ruta real en máquina del CEO | Detener — no estás en el repo correcto |
| `git remote -v` | URL de GitHub visible | Detener — repo sin remote no es oficial |
| `git status` | Rama activa, sin errores | Investigar antes de continuar |
| `git branch` | Rama correcta activa | Cambiar de rama antes de continuar |
| `git log` | Commits coinciden con CONTROL_CENTER | Investigar discrepancia |

---

## 5. Regla Operacional Obligatoria — Nada es Oficial Hasta

Para que cualquier cambio sea considerado **oficial y persistente**, debe cumplir las tres condiciones:

```
CONDICIÓN 1: Existe en filesystem real
    → El archivo está en el disco local del CEO, en la carpeta del repo

CONDICIÓN 2: Está en Git real con commit
    → git add + git commit ejecutados en el repo local real
    → El commit tiene mensaje descriptivo y autor correcto

CONDICIÓN 3: Está pusheado a GitHub
    → git push ejecutado
    → Commit hash verificable en github.com/junotgarcia/ByRousOS

SIN LAS TRES CONDICIONES = NO OFICIAL = NO EXISTE PARA EL PROYECTO
```

**Corolario:** ChatOperador NUNCA reporta un cambio como "hecho" o "commiteado" basándose en acciones del sandbox. Solo registra como oficial lo que el CEO confirma desde su entorno real, o lo que ChatOperador ejecuta directamente via VS Code Tunnel con push verificado.

---

## 5.1 Regla Operacional Obligatoria — Versionado de Archivos

Todo archivo generado para descarga debe incluir la versión en el nombre del archivo, dentro del documento, y en el changelog si aplica. Las tres instancias deben ser idénticas.

**Formato oficial:** `NOMBRE_vDD.MM.YY-HHam/pm.ext`

```
NOMBRE DEL ARCHIVO:   CONTROL_CENTER_v12.05.26-4pm.md
DENTRO DEL DOCUMENTO: **Versión:** v12.05.26-4pm
EN EL CHANGELOG:      | v12.05.26-4pm | 2026-05-12 | ... |
```

**Alcance — aplica a:**
- Documentos operacionales (`CONTROL_CENTER.md`, `TOOLS_AND_ENVIRONMENT.md`)
- Documentos maestros (`ByRousOS_Plan_Maestro`, `ByRousOS_Gobierno_Fase0`)
- Migrations SQL
- Cualquier output descargable generado en sesión

**Regla de consistencia:** Si la versión del nombre del archivo no coincide con la versión dentro del documento, el archivo no es oficial.

---

## 6. Flujo Correcto de Trabajo

```
┌─────────────────────────────────────────────────────────────┐
│                  FLUJO OFICIAL DE TRABAJO                    │
└─────────────────────────────────────────────────────────────┘

VÍA SANDBOX (documentos/borradores):
PASO 1 — ChatOperador genera en el chat
PASO 2 — CEO lleva al filesystem real
PASO 3 — Git commit en entorno real
PASO 4 — Push a GitHub
PASO 5 — Confirmación oficial

VÍA VS CODE TUNNEL (ejecución directa):
PASO 1 — CEO activa tunnel: code tunnel --name byrousos
PASO 2 — ChatOperador accede vía Chrome: https://vscode.dev/tunnel/byrousos
PASO 3 — ChatOperador verifica: pwd + git remote + git status
PASO 4 — ChatOperador crea/modifica archivos reales en terminal
PASO 5 — ChatOperador ejecuta git add + git commit + git push
PASO 6 — ChatOperador confirma push y registra hash en CONTROL_CENTER

⚠ En ambos flujos: sin push verificado = NO OFICIAL
```

---

## 7. Checklist Obligatorio al Iniciar Sesión

ChatOperador ejecuta este checklist mentalmente al inicio de cada sesión antes de tomar cualquier acción:

```
□ 1. ¿Leí CONTROL_CENTER.md del Project? (fase activa, último cambio, próxima acción)
□ 2. ¿Leí el Contexto Maestro actualizado?
□ 3. ¿El CEO confirmó conectividad real al repo? (git remote -v desde su terminal o VS Code Tunnel)
□ 4. ¿Tengo claro qué es sandbox y qué es real en esta sesión?
□ 5. ¿La tarea que voy a ejecutar requiere persistencia real?
      → Si sí: ¿está disponible VS Code Tunnel o Claude Code?
      → Si no: ¿está claro que el output es temporal/borrador?
□ 6. ¿Hay bloqueos activos en CONTROL_CENTER que impidan la tarea?
□ 7. ¿La tarea es nivel A (puedo hacer solo) o requiere aprobación CEO?
```

---

## 8. Resumen — Qué Puede y No Puede Hacer ChatOperador

| Acción | ChatOperador puede | Quién ejecuta realmente |
|--------|-------------------|------------------------|
| Generar contenido de archivos | ✅ Sí | ChatOperador (sandbox) |
| Validar sintaxis de código | ✅ Sí (en sandbox) | ChatOperador |
| Proponer comandos Git | ✅ Sí | CEO / Claude Code |
| Crear archivos reales en repo | ✅ Sí (vía VS Code Tunnel) | ChatOperador via Tunnel |
| Hacer commit real a GitHub | ✅ Sí (vía VS Code Tunnel) | ChatOperador via Tunnel |
| Hacer push a GitHub | ✅ Sí (vía VS Code Tunnel) | ChatOperador via Tunnel |
| Leer Project Files | ✅ Sí | ChatOperador |
| Escribir en Project Files | ❌ No (read-only) | CEO (sube manualmente) |
| Navegar GitHub/Supabase/n8n | ⚠ Solo con Chrome extension activa | Claude in Chrome |
| Acceder a VS Code Tunnel | ✅ Vía Claude in Chrome | Claude in Chrome |
| Registrar commit como oficial | Tras push verificado vía Tunnel o CEO | ChatOperador registra |

---

## Changelog

| Versión | Fecha | Cambio |
|---------|-------|--------|
| v12.05.26-12pm | 2026-05-12 | Versión inicial — herramientas, entornos, reglas operacionales |
| v12.05.26-4pm | 2026-05-12 | Sección 1.8 añadida: VS Code Tunnel `byrousos` · Sección 3 añadida: workflow, activación, verificación, sintaxis PS, limitación localhost · Tabla de entornos actualizada con Tunnel · Sección 8 actualizada con capacidades reales via Tunnel · Último commit oficial actualizado a `76efb42` |

---

*ByRousOS · TOOLS_AND_ENVIRONMENT v12.05.26-4pm · Mayo 2026 · Confidencial*  
*Este documento no se modifica sin aprobación del CEO. Es una regla de gobierno, no una preferencia operacional.*
