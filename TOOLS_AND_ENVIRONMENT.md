# TOOLS AND ENVIRONMENT — ByRousOS
**ChatOperador — Awareness Operacional Permanente**  
**Versión:** 1.0.0  
**Fecha:** 2026-05-11  
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
| Acceso real | Solo vía terminal del CEO o Claude Code |
| Fuente de verdad | ✅ GitHub es la única fuente de verdad de persistencia de código |
| Verificación | El CEO confirma commit hash en GitHub → ChatOperador lo registra |

### 1.7 Chrome / Browser (Claude in Chrome)

| Atributo | Valor |
|----------|-------|
| Qué es | Extensión de Claude que controla el navegador del CEO |
| Estado actual | No confirmado como activo en este entorno de trabajo |
| Uso potencial | Navegar GitHub, n8n, Supabase, Airtable en nombre del CEO |
| Prerequisito | CEO debe tener la extensión activa y conectada |

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
│ Filesystem real │ • Disco local del CEO                     │
│ (CEO + Claude   │ • Git con remote a GitHub                 │
│  Code)          │ • ✅ Persiste — es la realidad            │
│                 │ • ÚNICA fuente de verdad operacional      │
├─────────────────┼───────────────────────────────────────────┤
│ GitHub          │ • Repositorios remotos reales             │
│                 │ • ✅ Persiste — es el estado oficial      │
│                 │ • Solo accesible por terminal/Claude Code │
└─────────────────┴───────────────────────────────────────────┘
```

---

## 3. Cómo Verificar Conectividad Real Antes de Ejecutar

Antes de cualquier tarea que implique Git o persistencia, ejecutar esta verificación:

### 3.1 Comandos de verificación (en terminal real del CEO o Claude Code):

```bash
# 1. ¿Dónde estoy?
pwd
# Esperado: /ruta/real/a/ByRousOS en tu máquina

# 2. ¿Tengo remote configurado?
git remote -v
# Esperado: origin  https://github.com/junotgarcia/ByRousOS.git (fetch/push)

# 3. ¿En qué estado está el repo?
git status
# Esperado: rama limpia o con cambios pendientes — nunca "no remote"

# 4. ¿En qué rama estoy?
git branch
# Esperado: * main (o la rama activa del proyecto)

# 5. ¿Cuál es el último commit real?
git log --oneline -5
# Esperado: commits que coincidan con los registrados en CONTROL_CENTER.md
```

### 3.2 Criterios de confirmación:

| Verificación | Resultado esperado | Si falla |
|---|---|---|
| `pwd` | Ruta real en máquina del CEO | Detener — no estás en el repo correcto |
| `git remote -v` | URL de GitHub visible | Detener — repo sin remote no es oficial |
| `git status` | Rama activa, sin errores | Investigar antes de continuar |
| `git branch` | Rama correcta activa | Cambiar de rama antes de continuar |
| `git log` | Commits coinciden con CONTROL_CENTER | Investigar discrepancia |

---

## 4. Regla Operacional Obligatoria — Nada es Oficial Hasta

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

**Corolario:** ChatOperador NUNCA reporta un cambio como "hecho" o "commiteado" basándose en acciones del sandbox. Solo registra como oficial lo que el CEO confirma desde su entorno real.

---

## 5. Flujo Correcto de Trabajo

```
┌─────────────────────────────────────────────────────────────┐
│                  FLUJO OFICIAL DE TRABAJO                    │
└─────────────────────────────────────────────────────────────┘

PASO 1 — ChatOperador genera en el chat
    • Crea el contenido del archivo en el chat o en outputs/
    • Valida estructura y contenido
    • Entrega al CEO con instrucciones exactas

PASO 2 — CEO lleva al filesystem real
    • Descarga el archivo del chat
    • Lo copia a la carpeta correcta del repo local
    • O usa Claude Code para crearlo directamente

PASO 3 — Git commit en entorno real
    • git add <archivo>
    • git commit -m "mensaje descriptivo"
    • Ejecutado en terminal real o Claude Code

PASO 4 — Push a GitHub
    • git push origin main
    • CEO verifica en github.com que el commit existe

PASO 5 — Confirmación oficial
    • CEO reporta commit hash real al chat
    • ChatOperador registra el hash en CONTROL_CENTER.md
    • El cambio es ahora OFICIAL

⚠ Saltarse cualquier paso = el cambio NO ES OFICIAL
```

---

## 6. Checklist Obligatorio al Iniciar Sesión

ChatOperador ejecuta este checklist mentalmente al inicio de cada sesión antes de tomar cualquier acción:

```
□ 1. ¿Leí CONTROL_CENTER.md del Project? (fase activa, último cambio, próxima acción)
□ 2. ¿Leí el Contexto Maestro actualizado?
□ 3. ¿El CEO confirmó conectividad real al repo? (git remote -v desde su terminal)
□ 4. ¿Tengo claro qué es sandbox y qué es real en esta sesión?
□ 5. ¿La tarea que voy a ejecutar requiere persistencia real?
      → Si sí: ¿el CEO está listo para ejecutar en su entorno?
      → Si no: ¿está claro que el output es temporal/borrador?
□ 6. ¿Hay bloqueos activos en CONTROL_CENTER que impidan la tarea?
□ 7. ¿La tarea es nivel A (puedo hacer solo) o requiere aprobación CEO?
```

---

## 7. Resumen — Qué Puede y No Puede Hacer ChatOperador

| Acción | ChatOperador puede | Quién ejecuta realmente |
|--------|-------------------|------------------------|
| Generar contenido de archivos | ✅ Sí | ChatOperador |
| Validar sintaxis de código | ✅ Sí (en sandbox) | ChatOperador |
| Proponer comandos Git | ✅ Sí | CEO / Claude Code |
| Hacer commit real a GitHub | ❌ No | CEO / Claude Code |
| Hacer push a GitHub | ❌ No | CEO / Claude Code |
| Leer Project Files | ✅ Sí | ChatOperador |
| Escribir en Project Files | ❌ No (read-only) | CEO (sube manualmente) |
| Navegar GitHub/Supabase/n8n | ⚠ Solo con Chrome extension activa | Claude in Chrome |
| Registrar commit como oficial | Solo tras confirmación del CEO | CEO confirma → ChatOperador registra |

---

*ByRousOS · TOOLS_AND_ENVIRONMENT v1.0.0 · Mayo 2026 · Confidencial*  
*Este documento no se modifica sin aprobación del CEO. Es una regla de gobierno, no una preferencia operacional.*
