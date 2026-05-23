# Smart Spend Backend — Agent Rules

> Subproyecto del monorepo `smart_spend_app/`, en `smart_spend_app/smart_spend_backend/`.
> Hermanos: `smart_spend_app_mobile/` (Flutter), `smart_spend_app_web/` (futuro).
> Deploy en Railway con **Root Directory = `smart_spend_backend`**.

## Clean Architecture (NO EXCEPCIÓN)

Tres capas con aislamiento estricto:

```
src/domain/       → CERO imports de frameworks. Solo TypeScript puro.
src/application/  → CERO imports de NestJS, Mongoose, Passport. Solo puertos del dominio.
src/infrastructure/ → NestJS, Mongoose, Passport, controladores. Única capa con dependencias externas.
```

**Regla de oro**: si un archivo en `domain/` o `application/` importa algo de `@nestjs/*`, `mongoose`, o `passport`, está MAL.

## Stack

| Componente | Tecnología |
|------------|-----------|
| Runtime | Node.js |
| Framework | NestJS 11 |
| Lenguaje | TypeScript 5.7 (strict) |
| Base de datos | MongoDB Atlas (Mongoose 9) |
| Auth | Apple OAuth + Google OAuth (idToken verification) + JWT |
| Testing | Jest 30 + supertest |
| Validación | class-validator + class-transformer |
| Config | @nestjs/config + Joi |

## Auth Module — Decisiones y Tradeoffs

### Flujo: idToken verification (mobile-first)
- El frontend Flutter obtiene idToken vía SDK nativo (Google Sign-In / Apple Sign-In)
- Backend verifica el idToken contra el provider (NO PKCE, NO authorization codes, NO redirects)
- Backend emite JWT propio (access 15min + refresh 7 días)

### G3 Tradeoff: ignoreExpiration en JwtStrategy (RESUELTO)
- `JwtStrategy` usa `ignoreExpiration: true` por diseño, EXCLUSIVO para `/auth/refresh` (extrae userId de tokens vencidos).
- Rutas protegidas reales (Backup) usan `JwtAccessStrategy` / `JwtAccessGuard` con `ignoreExpiration: false`.
- Regla: cualquier ruta de recurso protegido NUEVA debe usar `JwtAccessGuard`, no `JwtAuthGuard`.

## Backup Module

- `POST /backup` (body `{ compras: [...] }`) y `GET /backup` (devuelve `{ compras, updatedAt }`, 404 si no hay).
- Protegido por `JwtAccessGuard`. Un documento por usuario en la colección `backups` (upsert, snapshot sin historial).
- El array `compras` es el export crudo de la app Flutter (`exportToJson`), validado en el borde con DTOs.

### Refresh Token Theft Detection
- User doc tiene `refreshTokenHash` + `previousRefreshTokenHash`
- Si se detecta reúso de un token ya revocado → se revocan TODOS los tokens del usuario

### Apple Name en primer login
- Apple solo manda `name` en el primer login. Logins posteriores: `name: null`
- `User.mergeNonNil()` preserva el nombre almacenado si el incoming es null

## Convenciones de Testing

- Unit tests: `*.spec.ts` junto al archivo que testean
- Integration tests: controller-level con `Test.createTestingModule` + `supertest` + `mongodb-memory-server`
- Correr antes de commit: `pnpm test && pnpm run build`

## Commands

> Gestor de paquetes: **pnpm** (lockfile `pnpm-lock.yaml`). Builds nativos aprobados en `pnpm-workspace.yaml` (`allowBuilds`).

```bash
pnpm install         # Instalar dependencias
pnpm run start:dev   # Desarrollo con hot reload
pnpm test            # Tests (Jest)
pnpm run test:e2e    # E2E tests
pnpm run build       # Build de producción
pnpm run lint        # ESLint + Prettier
```

## Configuración requerida (.env)

```
JWT_SECRET=<min 16 chars>
JWT_EXPIRY=15m
GOOGLE_CLIENT_ID=<google-oauth-client-id>   # Web Client ID; debe coincidir con el serverClientId del front
MONGODB_URI=<mongodb-atlas-connection-string>

# Apple Sign-In — OPCIONAL (requiere Apple Developer Program pago).
# Si se omiten, el backend arranca igual y solo se deshabilita el login con Apple.
APPLE_CLIENT_ID=<app-bundle-id>
APPLE_TEAM_ID=<apple-team-id>
APPLE_KEY_ID=<apple-key-id>
APPLE_PRIVATE_KEY=<p8-file-contents>
```

> Nota: no setear `PORT` en Railway (lo inyecta la plataforma).
