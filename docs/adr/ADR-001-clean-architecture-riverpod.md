# ADR-001: Clean Architecture feature-first avec Riverpod et repositories

**État** : Accepté

## Contexte

L’application mobile `pharmacie_de_garde` doit exposer au grand public ivoirien la recherche de pharmacies de garde, tout en restant évolutive face à :

- des sources de données instables (API locale, bascule mock → remote) ;
- des besoins offline partiels (urgences, session) ;
- une UI Flutter susceptibles de changer indépendamment du domaine ;
- une équipe devant brancher géolocalisation, avis et signalements sans couplage fort.

Les alternatives fréquentes (tout UI + appels HTTP dans les widgets, BLoC unique global, GetIt comme DI exclusive) auraient soit freiné les tests, soit multiplié les frameworks d’état.

## Décision

Nous retenons une **Clean Architecture feature-first** combinée à **Riverpod** comme composition root :

1. Chaque feature riche (`auth`, `pharmacy`, `emergency`, `review`) expose les couches :
   - **domain** — entities + interfaces repository + failures ;
   - **data** — models, datasources remote/local, `*RepositoryImpl` ;
   - **presentation** — pages + `StateNotifier` Riverpod.
2. Les erreurs métier passent par **`Either<Failure, T>`** (`dartz`).
3. La DI et l’état UI sont centralisés dans `lib/core/providers/providers.dart` (`Provider` / `StateNotifierProvider`).
4. Le réseau repose sur un `ApiClient` HTTP commun (`lib/core/network`) et des constantes d’URL (`api_constants.dart`).
5. Les features purement UX (`splash`, `onboarding`, `home`, `settings`, …) restent plus légères mais consomment les notifiers / repositories des features riches.

GetIt et go_router sont présents dans `pubspec.yaml` mais **non adoptés** comme standards runtime ; la navigation actuelle utilise `MaterialApp` + routes nommées / `Navigator`.

## Conséquences

### Avantages

- **Séparation des préoccupations** : UI interchangeabled sans réécrire le domaine.
- **Testabilité** : repositories et datasources mockables derrière des interfaces.
- **Évolutivité API/cache** : possible de durcir le cache pharmacies (mémoire → prefs/DB) dans `data/` seul.
- **Homogénéité** : pattern déjà appliqué sur les features critiques mobile.

### Points d’attention / risques

- **Hétérogénéité résiduelle** : certaines méthodes pharmacy appellent encore des mocks ; dette à résorber dans `data/`.
- **Caches inégaux** : urgences persistées (SharedPreferences) vs pharmacies en mémoire seule.
- **Dépendances mortes** : `go_router`, `get_it`, OAuth Google/Facebook, codegen Riverpod non utilisés — coût de maintenance `pubspec`.
- **Use cases sous-employés** : certains notifiers appellent directement le repository (à harmoniser).
- **Sécurité** : pas de JWT ; identification via téléphone / `clientId` — dépend du durcissement backend.
- **Navigation** : trancher explicitement Material routes vs adoption réelle de `go_router` (futur ADR).
