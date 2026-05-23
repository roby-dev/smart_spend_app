# SmartSpend — Monorepo

App de seguimiento de gastos personales. Este repositorio es el **paraguas** que agrupa todos los subproyectos de la plataforma.

## Estructura

```
smart_spend_app/                 ← repo git (paraguas)
├── smart_spend_app_mobile/      ← App Flutter (mobile). Ver su README.
├── smart_spend_backend/         ← API NestJS + MongoDB Atlas. Ver su CONTEXT.md / AGENTS.md.
└── smart_spend_app_web/         ← (futuro) App web.
```

Cada subproyecto tiene su propio `.gitignore`, sus dependencias y su toolchain. El paraguas solo coordina.

## Subproyectos

| Proyecto | Stack | Estado |
|----------|-------|--------|
| `smart_spend_app_mobile` | Flutter 3.41, Riverpod, Drift (SQLite) | Activo |
| `smart_spend_backend` | NestJS 11, MongoDB Atlas, Clean Architecture | Auth + Backup implementados |
| `smart_spend_app_web` | — | No iniciado |

## Cómo trabajar

Cada subproyecto se opera desde su propia carpeta:

```bash
# Mobile
cd smart_spend_app_mobile && flutter pub get && flutter run

# Backend
cd smart_spend_backend && npm install && npm run start:dev
```

## Deploy

- **Backend → Railway**: el servicio debe apuntar a **Root Directory = `smart_spend_backend`**.
- **Mobile**: sin deploy automático (build manual de APK / stores).

## Convenciones

- Un solo repo git, en la raíz paraguas.
- Commits convencionales.
- Las decisiones de arquitectura del backend viven en `smart_spend_backend/CONTEXT.md` y sus reglas en `smart_spend_backend/AGENTS.md`.
