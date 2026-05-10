# ByRous OS

AI-ready operating backbone for **ByRous** (vitrina hoy → inventario, CRM, dashboards, automatización y comercio).

## Stack

| Capa         | Tecnología                                                          | Motivo                                                                         |
| ------------ | ------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Web UI & API | **Next.js 15** (App Router), **React 19**, **TypeScript**           | RSC, rutas paralelas cuando escale el dashboard, Route Handlers para webhooks  |
| Estilos      | **Tailwind CSS v4**, PostCSS                                        | Iteración rápida y diseño sistemático (`@theme` en `app/globals.css`)          |
| Validación   | **Zod**                                                             | Peticiones (`/api/*`), `.env`, futuros payloads de servidor                    |
| IA           | **Vercel AI SDK** (`ai`), **@ai-sdk/openai**, **@ai-sdk/anthropic** | `generateText` hoy; mismo paquete habilitará streaming, herramientas y agentes |

**Próximos encajes naturales**: PostgreSQL + **Prisma** (datos), **Inngest** / Trigger.dev (jobs), **Better Auth** o proveedor SSO (accesos internos vs tienda).

## Frontend (estructura)

El UI vive mayormente aquí:

- `app/` — rutas (`layout.tsx`, `page.tsx`, segmentos futuros tipo `(dashboard)/`)
- `components/landing/` — vitrina inicial
- `components/ui/` — primitivas reutilizables
- `config/` — constantes públicas (`SITE`, `getInstagramUrl`)
- `public/` — assets estáticos (`robots.txt`, imágenes)
- `hooks/` — efectos/helpers compartidos (vacío inicialmente)

`domains/` agrupa tipos de negocio (inventario, CRM) antes de modelo de BD.

## API

| Ruta                 | Descripción                                               |
| -------------------- | --------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `GET /api/health`    | Comprobación básica de servicio                           |
| `GET /api/ai/status` | Si parece configurada una clave IA (sin filtrar secretos) |
| `POST /api/ai/chat`  | JSON `{ "messages": [{ "role":"user"                      | "assistant" | "system", "content": "..." }] }`. **Sin auth** — sólo desarrollo hasta integremos política de acceso. |

Capa servidor compartida: `lib/` (`env.server.ts`, `ai/`).

## Desarrollo

```bash
cp .env.example .env.local   # Opcional según necesites
npm install
npm run dev
```

Otros comandos útiles:

```bash
npm run build && npm run start
npm run lint
npm run typecheck
npm run format
npm run format:check
```

## Variables de entorno

Ver `.env.example`. Claves públicas llevan prefijo `NEXT_PUBLIC_`. Todo lo demás es **solo servidor**.

## Principios de operación técnica

Decidir y construir hasta cruzar un hito estable; sólo preguntamos por cuenta externa/factura/acciones destructivas o bifurcación de negocio.
