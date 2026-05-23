# SmartSpend — Mobile (Flutter)

App de seguimiento de gastos personales. Subproyecto mobile del monorepo `smart_spend_app/`.

Organiza compras en listas, trackea precios de ítems contra presupuestos, y respalda los datos en la nube contra el backend propio (`../smart_spend_backend`).

## Versión

- **App version:** 1.1.0+2
- **Flutter SDK:** 3.11.0 (Dart) / canal estable
- **Min Android SDK:** 29
- **Package name:** `smart_spend_app` (los imports usan `package:smart_spend_app/...`)

## Arquitectura

Arquitectura por capas con separación de responsabilidades:

```
lib/
├── config/
│   ├── database/   # Drift (SQLite)
│   ├── router/     # GoRouter
│   ├── theme/      # Theming
│   ├── env/        # app_env.dart — config de backend + Google Sign-In
│   └── network/    # dio_client.dart — Dio + interceptor de auth/refresh
├── constants/      # Colores y constantes
├── data/
│   ├── datasources/local/   # Drift datasources
│   └── repositories/        # Implementaciones de repositorio
├── domain/
│   ├── models/              # Modelos de negocio
│   └── repositories/        # Contratos (interfaces)
├── features/
│   ├── home/                # Listas de compras
│   ├── compra_detalle/      # Detalle (ítems) de una compra
│   ├── compras_archivadas/  # Compras archivadas
│   ├── auth/                # Google Sign-In + sesión (JWT del backend)
│   ├── cloud_backup/        # Backup/restore contra el backend
│   └── shared/              # Providers, widgets y utilidades comunes
└── main.dart
```

**Estado:** Riverpod 3.x con patrón Notifier (`NotifierProvider`).
**Persistencia local:** Drift (SQLite) con code generation.
**Navegación:** GoRouter.

## Dependencias

| Paquete | Propósito |
|---------|-----------|
| flutter_riverpod / riverpod_annotation | State management + code-gen |
| go_router | Navegación declarativa |
| drift / drift_flutter | Persistencia SQLite reactiva |
| dio | Cliente HTTP hacia el backend |
| google_sign_in (7.x) | Login con Google (devuelve idToken) |
| flutter_secure_storage | Guarda los JWT (access/refresh) |
| file_picker / share_plus | Import/export local de JSON |
| intl | Formato de fechas (es_PE) |
| flutter_svg / visibility_detector | UI |

> No usa Firebase, Google Drive ni Gemini. La autenticación y el backup son contra el backend propio NestJS.

## Backup en la nube

1. La app obtiene el JSON de `exportToJson()` (array de compras con detalles).
2. Google Sign-In → idToken → `POST /auth/login` del backend → guarda el JWT.
3. `POST /backup` sube el snapshot; `GET /backup` lo baja y se reimporta con `importFromJson()`.
4. UI: ícono de menú (drawer) → "Backup en la nube" / "Restaurar desde la nube".

## Configuración requerida

Antes de usar el backup, completar `lib/config/env/app_env.dart`:

- `backendBaseUrl` → URL pública de Railway del backend (sin slash final).
- `googleServerClientId` → el **Web** OAuth Client ID de Google Cloud. Debe ser **el mismo** que `GOOGLE_CLIENT_ID` del backend (el backend valida el `aud` del idToken contra ese valor).

Se pueden inyectar en build sin tocar código:

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=https://tu-api.up.railway.app \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
```

### Google Cloud (Android)

Para que el login funcione en dispositivo, en el **mismo** proyecto de Google Cloud que el Web client:
- Crear un **OAuth client de Android** con el **SHA-1** de la app (`cd android && ./gradlew signingReport`).

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift + Riverpod
flutter run
```

## Build

```bash
flutter build apk --release
```

## Licencia

Software propietario. Todos los derechos reservados.
