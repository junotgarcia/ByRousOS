# TOOLS AND ENVIRONMENT — ByRousOS
**ChatOperador — Awareness Operacional Permanente**
**Versión:** v4.2
**Fecha:** 2026-05-13
**Commit:** 36c9be1
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
| Último commit oficial | `36c9be1` — `fix(audit): verify append-only enforcement with transaction -- Phase 1 Step 6` |

### 1.7 Chrome / Browser (Claude in Chrome)

| Atributo | Valor |
|----------|-------|
| Qué es | Extensión de Claude que controla el navegador del CEO |
| Estado actual | ✅ Operacional — confirmado 2026-05-13 |
| Browser activo | Edge (Windows) · deviceId `fc7f0c64` |
| Supabase | ✅ Navegable y operable — dashboard, SQL Editor accesibles |
| Vercel | ⚠ Bloqueado por proxy de red — ChatOP no puede navegar vercel.com directamente |
| Capacidad verificada | Navegación, screenshots, ejecución de queries SQL en Supabase, VS Code Tunnel |
| Limitación 1 | Inestabilidad parcial con Monaco Editor (SQL Editor de Supabase) — tabs_context_mcp funciona pero interacción pesada puede degradarse |
| Limitación 2 | Acciones pesadas (screenshot + click secuencial) pueden causar timeout — reintentar o simplificar la secuencia |
| Limitación 3 | No introduce credenciales ni ejecuta acciones irreversibles — requiere confirmación del CEO |
| Limitación 4 | URI schemes custom (`vscode://`, `file://`) bloqueados por proxy de red |
| Limitación 5 | vercel.com bloqueado por proxy — validación de endpoints requiere CEO o curl directo |
| Uso correcto | Verificación de estado, navegación guiada, queries SQL en Supabase, acceso a VS Code Tunnel |

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
| Estado | ✅ Operacional — confirmado 2026-05-13 · usado para Pasos 4, 5 y 6 de Fase 1 |
| Sintaxis terminal | PowerShell — usar `;` como separador, NO `&&` |
| Limitación 1 | Timeout de extensión Chrome bajo operación pesada — reconectar con `tabs_context_mcp` |
| Limitación 2 | Modales de Copilot/GitHub AI pueden bloquear la vista — cerrar antes de operar |
| Limitación 3 | `localhost:3000` del dev server NO es accesible via tunnel — usar IP de red o Vercel |
| Limitación 4 | `Invoke-WebRequest` desde terminal del tunnel apunta al servidor remoto, no a la máquina local |
| Limitación 5 | Tab puede congelarse durante operaciones pesadas (npm build) — esperar recuperación o recargar |
| Uso correcto | Integración real de archivos, commits reales, git push, verificación de estado del repo |
| Uso incorrecto | Asumir que `localhost` del tunnel = `localhost` del CEO |

### 1.9 Vercel — `by-rous-os`

| Atributo | Valor |
|----------|-------|
| Qué es | Plataforma de deploy para ByRousOS (Next.js) |
| URL producción | https://by-rous-os.vercel.app |
| Estado | ✅ Operacional — confirmado 2026-05-13 |
| Deploy | Automático en cada push a `main` |
| Variables configuradas | `DATABASE_URL` · `NEXT_PUBLIC_SUPABASE_URL` · `NEXT_PUBLIC_SUPABASE_ANON_KEY` · `SUPABASE_SERVICE_ROLE_KEY` |
| Acceso desde chat | ❌ vercel.com bloqueado por proxy — CEO gestiona directamente |
| Lección aprendida | Build falló por encoding UTF-16 en archivo TypeScript — usar siempre UTF-8 sin BOM para escritura de archivos desde PowerShell |

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
│                 │ • Filesystem real del CEO                 │
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
│ Vercel          │ • https://by-rous-os.vercel.app           │
│                 │ • Deploy automático desde main            │
│                 │ • ✅ Operacional desde 2026-05-13         │
│                 │ • Variables de entorno configuradas       │
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
| Heredoc `<< 'EOF'` | NO usar — introduce encoding incorrecto |
| `tail -n 5` | `Select-Object -Last 5` |

### 3.5 Regla Crítica — Encoding de Archivos

```
NUNCA usar PowerShell heredoc (@'...'@) con Set-Content para
escribir archivos TypeScript o código fuente.

PowerShell Set-Content y Out-File usan UTF-16 por defecto
en algunos contextos — esto rompe el build de Next.js/Vercel.

MÉTODO CORRECTO para modificar archivos de código:
- Usar node script externo (.js) con fs.writeFileSync(..., 'utf8')
- Generar el script en bash_tool (garantiza ASCII/UTF-8)
- CEO descarga y copia el script al repo
- ChatOP ejecuta: node .\script.js desde el tunnel
- Verificar con npm run build antes de commit

LECCIÓN APRENDIDA (2026-05-13):
  Intento con PowerShell heredoc → build falló en Vercel
  con "stream did not contain valid UTF-8" y caracteres
  de control invisibles (\u{206d}).
  Corrección: git checkout commit_sano -- archivo.ts
  + node script UTF-8 limpio generado en bash_tool.
```

### 3.6 Limitación Conocida — localhost

El dev server (`npm run dev`) corre en `localhost:3000` de la **máquina del CEO**, no del servidor del tunnel. Para validar endpoints del dev server:

- ✅ El CEO abre `http://localhost:3000/api/...` en su browser local
- ❌ `Invoke-WebRequest http://localhost:3000/...` desde la terminal del tunnel **no funciona**
- ✅ Para acceso externo: usar la URL de Vercel: https://by-rous-os.vercel.app

---

## 4. Regla Operacional Obligatoria — Nada es Oficial Hasta

```
CONDICIÓN 1: Existe en filesystem real
CONDICIÓN 2: Está en Git real con commit
CONDICIÓN 3: Está pusheado a GitHub

SIN LAS TRES CONDICIONES = NO OFICIAL = NO EXISTE PARA EL PROYECTO
```

---

## 4.1 Regla Operacional Obligatoria — Versionado de Archivos

**Formato oficial vigente:** `vN.N · YYYY-MM-DD · commitHash`

El commit hash de GitHub es la trazabilidad temporal oficial.

Formato anterior `vDD.MM.YY-HHam/pm` queda deprecado — no usar en documentos nuevos.

---

## 5. Flujo Correcto de Trabajo

```
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

VÍA NODE SCRIPT (modificación de código fuente):
PASO 1 — ChatOperador genera script .js en bash_tool (UTF-8 garantizado)
PASO 2 — CEO descarga script y lo copia al repo
PASO 3 — ChatOperador ejecuta: node .\script.js desde tunnel
PASO 4 — ChatOperador ejecuta npm run build para verificar
PASO 5 — Si build pasa: Remove-Item script + git add + commit + push
PASO 6 — ChatOperador confirma push y registra hash

⚠ En todos los flujos: sin push verificado = NO OFICIAL
```

---

## 6. Checklist Obligatorio al Iniciar Sesión

```
□ 1. ¿Leí CONTROL_CENTER.md del Project? (fase activa, último commit, próxima acción)
□ 2. ¿Leí CURRENT_SYSTEM_STATE actualizado?
□ 3. ¿El CEO confirmó conectividad real al repo? (git remote -v desde su terminal o VS Code Tunnel)
□ 4. ¿Tengo claro qué es sandbox y qué es real en esta sesión?
□ 5. ¿La tarea que voy a ejecutar requiere persistencia real?
      → Si sí: ¿está disponible VS Code Tunnel o Claude Code?
      → Si no: ¿está claro que el output es temporal/borrador?
□ 6. ¿Hay bloqueos activos en CONTROL_CENTER que impidan la tarea?
□ 7. ¿La tarea es nivel A (puedo hacer solo) o requiere aprobación CEO?
□ 8. ¿Si voy a modificar archivos de código, usaré node script UTF-8 en lugar de PowerShell heredoc?
```

---

## 7. Resumen — Qué Puede y No Puede Hacer ChatOperador

| Acción | ChatOperador puede | Quién ejecuta realmente |
|--------|-------------------|------------------------|
| Generar contenido de archivos | ✅ Sí | ChatOperador (sandbox) |
| Validar sintaxis de código | ✅ Sí (en sandbox) | ChatOperador |
| Proponer comandos Git | ✅ Sí | CEO / Claude Code |
| Crear archivos reales en repo | ✅ Sí (vía VS Code Tunnel) | ChatOperador via Tunnel |
| Hacer commit real a GitHub | ✅ Sí (vía VS Code Tunnel) | ChatOperador via Tunnel |
| Hacer push a GitHub | ✅ Sí (vía VS Code Tunnel) | ChatOperador via Tunnel |
| Modificar archivos TypeScript | ✅ Vía node script UTF-8 | ChatOperador via Tunnel |
| Ejecutar SQL en Supabase | ✅ Vía SQL Editor Chrome (con autorización CEO) | Claude in Chrome |
| Leer Project Files | ✅ Sí | ChatOperador |
| Escribir en Project Files | ❌ No (read-only) | CEO (sube manualmente) |
| Navegar GitHub/Supabase/n8n | ⚠ Solo con Chrome extension activa | Claude in Chrome |
| Navegar vercel.com | ❌ Bloqueado por proxy | CEO directamente |
| Acceder a VS Code Tunnel | ✅ Vía Claude in Chrome | Claude in Chrome |
| Registrar commit como oficial | Tras push verificado vía Tunnel o CEO | ChatOperador registra |

---

## Changelog

| Versión | Fecha | Commit | Cambio |
|---------|-------|--------|--------|
| v12.05.26-12pm | 2026-05-12 | — | Versión inicial — herramientas, entornos, reglas operacionales |
| v12.05.26-4pm | 2026-05-12 | `76efb42` | VS Code Tunnel `byrousos` · workflow completo · sintaxis PS · limitación localhost |
| v4.2 | 2026-05-13 | `36c9be1` | Sección 1.9 añadida: Vercel operativo · lección encoding PowerShell → UTF-16 bug · node script como método oficial · Sección 3.5 regla encoding · Sección 3.6 localhost · flujo via node script añadido · checklist actualizado · tabla resumen actualizada |

---

*ByRousOS · TOOLS_AND_ENVIRONMENT v4.2 · 2026-05-13 · commit 36c9be1 · Confidencial*
*Este documento no se modifica sin aprobación del CEO. Es una regla de gobierno, no una preferencia operacional.*
