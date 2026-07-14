# 03 — Spécifications techniques

## Architecture

Clean Architecture **feature-first** + **Riverpod**. Décision structurante : [ADR-001](../docs/adr/ADR-001-clean-architecture-riverpod.md).

```
lib/
  main.dart / app.dart
  config/          # themes, routes
  core/            # network, errors, providers, services, constants
  features/        # auth, pharmacy, emergency, review, home, ...
  shared/          # widgets, styles, extensions
```

## Stack

| Élément | Choix |
|---------|-------|
| SDK Dart | ^3.4.0 |
| Flutter (outil) | 3.32.0 (local) |
| État / DI | flutter_riverpod ^2.5.1 (lock 2.6.1) |
| HTTP | `http` ^1.2.0 |
| Erreurs | `dartz` Either |
| Geo | `geolocator`, `permission_handler` |
| Offline check | `connectivity_plus` |
| Persist locale | `shared_preferences` |
| Notifs locales | `flutter_local_notifications` (non branché au flux principal) |
| Navigation | MaterialApp routes (go_router déclaré mais inutilisé) |

## Couches type (feature riche)

```
presentation (Notifier + Page)
    ↓
domain (Entity, Repository interface, Failure)
    ↑
data (Model, Remote/Local DataSource, RepositoryImpl)
```

Composition root : `lib/core/providers/providers.dart`.

## Réseau

| Plateforme | Base URL |
|------------|----------|
| Android emulator | `http://10.0.2.2:8080/api` |
| iOS / desktop | `http://localhost:8080/api` |

Client : `ApiClient` — timeout 30s, méthodes get/getList/post/put/delete. **Pas de Bearer token**.

## Offline & cache

| Donnée | Stratégie |
|--------|-----------|
| Auth session | SharedPreferences |
| Emergency numbers | SharedPreferences si réseau ok puis cache |
| Pharmacies | Cache **mémoire** uniquement |
| Network gate | `NetworkInfo` + connectivity_plus |

## Services device

- `LocationService` / permissions GPS.
- `GeocodingServiceImpl` : reverse geocode **mock Abidjan** (pas d’API Maps reverse réelle).
- `NotificationServiceImpl` : prêt mais non orchestré au démarrage.

## Dette connue (pour maintenance)

- Dépendances non utilisées : GetIt, go_router, Google/Facebook auth, riverpod_generator sans `.g.dart`.
- Mocks résiduels sur certaines méthodes pharmacy remote.
- Remnants dossiers `bloc/` vides / events legacy.
