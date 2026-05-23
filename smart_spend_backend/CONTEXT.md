# Smart Spend Backend — Context

Backend API para SmartSpend, una app Flutter de tracking de gastos personales. Provee autenticación (Apple/Google OAuth), gestión de usuarios, y futura sincronización de datos (listas de compras, ítems, presupuestos).

## Estado actual

| Módulo | Estado | Tests |
|--------|--------|-------|
| **Auth** | ✅ Implementado | 67/67 |
| **Backup** | ✅ Implementado | 18/18 |
| Purchase Lists | 🔲 Pendiente | — |
| Data Sync | 🔲 Pendiente | — |

## Stack

| Componente | Tecnología |
|------------|-----------|
| Runtime | Node.js |
| Framework | NestJS 11 |
| Lenguaje | TypeScript 5.7 (strict) |
| Base de datos | MongoDB Atlas (Mongoose 9) |
| Auth | Apple OAuth + Google OAuth (idToken verification) + JWT |
| Testing | Jest 30 + supertest + mongodb-memory-server |
| Linter | ESLint |
| Formatter | Prettier |

## Arquitectura

Clean Architecture con tres capas:

```
src/
├── config/
│   └── app.config.ts              # Validación Joi de variables de entorno
├── domain/
│   ├── entities/user.entity.ts    # User con create(), fromPersistence(), mergeNonNil()
│   ├── value-objects/             # AuthProvider ('google'|'apple'), TokenPair
│   ├── ports/user-repository.port.ts  # IUserRepository (5 métodos)
│   └── exceptions/auth.exceptions.ts  # InvalidCredentialsError, TokenRevokedError
├── application/
│   ├── ports/                     # ITokenVerifier, ITokenService
│   ├── dto/                       # LoginRequestDto, TokenResponseDto, RefreshRequestDto
│   └── use-cases/                 # LoginUseCase, RefreshTokenUseCase, LogoutUseCase
├── infrastructure/
│   ├── auth/                      # AuthModule, AuthController, JwtStrategy, JwtAuthGuard, TokenService
│   ├── auth/verifiers/            # GoogleTokenVerifier, AppleTokenVerifier, VerifierRegistryProvider
│   ├── persistence/               # MongoUserRepository, UserSchema (Mongoose)
│   └── common/                    # HttpExceptionFilter
├── app.module.ts                  # ConfigModule, MongooseModule, AuthModule
└── main.ts                        # ValidationPipe global + HttpExceptionFilter
```

- **Domain**: no conoce frameworks ni bases de datos. Pura lógica de negocio.
- **Application**: orquesta los casos de uso usando interfaces del dominio.
- **Infrastructure**: implementa las interfaces con tecnología concreta (NestJS, Mongoose, Passport).

## Auth Module (✅ implementado)

### Flujo
1. Frontend Flutter obtiene `idToken` de Google Sign-In o Apple Sign-In (SDK nativo)
2. `POST /auth/login` → backend verifica el idToken contra el provider
3. Backend registra o recupera usuario en MongoDB
4. Backend emite JWT propio: access token (15 min) + refresh token (7 días)
5. Requests subsiguientes: `Authorization: Bearer <accessToken>`
6. `POST /auth/refresh` → rota tokens, con detección de robo

### Endpoints
```
POST /auth/login     { provider: "google"|"apple", idToken: string }
POST /auth/refresh   { refreshToken: string }
POST /auth/logout    { refreshToken: string } + Authorization header
```

### Decisiones de diseño
- **Verificadores**: servicios custom (google-auth-library, apple-signin-auth). NO Passport OAuth strategies.
- **Guard**: passport-jwt solo para proteger rutas, NO para login.
- **Refresh tokens**: rotación con whitelist embebida en User doc. Detección de robo vía `previousRefreshTokenHash`.
- **Apple name**: solo en primer login → `mergeNonNil()` preserva el nombre almacenado.

### Tradeoff G3 (✅ resuelto)
`JwtStrategy` usa `ignoreExpiration: true` para extraer userId de tokens vencidos en el refresh. Las rutas protegidas reales (backup) usan `JwtAccessStrategy`/`JwtAccessGuard` con `ignoreExpiration: false`.

## Backup Module (✅ implementado)

### Flujo
1. La app obtiene el JSON de `exportToJson()` (array de compras con detalles anidados).
2. `POST /backup` con `Authorization: Bearer <accessToken>` y body `{ compras: [...] }` → upsert de un documento por usuario (se sobrescribe).
3. `GET /backup` → devuelve `{ compras: [...], updatedAt }` para restaurar vía `importFromJson()`.

### Endpoints (protegidos por JwtAccessGuard)
```
POST /backup   { compras: CompraDto[] }   → { compras, updatedAt }
GET  /backup                              → { compras, updatedAt }  (404 si no hay backup)
```

### Forma de los datos
```
CompraDto        { titulo, fecha (ISO), archivado, presupuesto: number|null, orden, detalles: CompraDetalleDto[] }
CompraDetalleDto { nombre, precio, fecha (ISO) }
```
Validado en el borde con class-validator. Un doc por usuario en la colección `backups`, indexado por `userId` único.

### Decisiones de diseño
- **Snapshot, no historial**: cada backup sobrescribe el anterior (`findOneAndUpdate` con upsert). Sin versionado por ahora.
- **JwtAccessGuard** (`ignoreExpiration: false`): primer set de rutas protegidas reales → resuelve el tradeoff **G3**. El `JwtStrategy` original (que ignora expiración) queda exclusivo para `/auth/refresh`.

## Monorepo

Este backend es un subproyecto del monorepo `smart_spend_app/`, en `smart_spend_app/smart_spend_backend/`. Hermanos: `smart_spend_app_mobile/` (Flutter) y `smart_spend_app_web/` (futuro). Un solo repo git (el paraguas). La app mobile no tiene deploy automático, por eso conviven sin fricción.

### Deploy en Railway (monorepo)
- El servicio de Railway debe apuntar a **Root Directory = `smart_spend_backend`**.
- `railway.json` (en `smart_spend_backend/`) define build (`npm run build`) y start (`npm run start:prod`).
- Variables de entorno (ver `.env.example`) se cargan en el dashboard de Railway, no en el repo.

## Frontend companion

**SmartSpend App mobile** (`../smart_spend_app_mobile/`) — Flutter 3.41.0, Riverpod, Drift (SQLite).

Firebase Auth fue removido. Se migró a autenticación contra este backend.

### Paquetes de auth necesarios en el frontend
- `google_sign_in` ≥ 7.2.0
- Apple Sign-In (nativo en Flutter, no requiere paquete extra en iOS)

## Decisiones resueltas

- [x] Estrategia de refresh tokens → rotación con whitelist + detección de robo
- [x] API REST para auth → `POST /auth/login`, `/auth/refresh`, `/auth/logout`
- [x] Verificación de idToken → servicios custom, no Passport OAuth strategies

## Decisiones pendientes

- [ ] Estructura de colecciones MongoDB (embebido vs referencias para ítems de lista)
- [ ] API REST vs GraphQL para la sincronización de datos
- [ ] Manejo de conflictos en sincronización offline-first
- [ ] Rate limiting en endpoints de auth
- [ ] Server-to-server notifications de Apple (account deletion compliance)
- [ ] Estrategia de multi-dispositivo para refresh tokens (actualmente single-device)
