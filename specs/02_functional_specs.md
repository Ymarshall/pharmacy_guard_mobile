# 02 — Spécifications fonctionnelles

## Personas

- **Citoyen urgent** : veut la garde la plus proche maintenant.
- **Citoyen informé** : cherche une pharmacie connue, lit les avis.
- **Citoyen contributeur** : signale une erreur de liste / laisse une note.

## User stories

| ID | En tant que | Je veux | Afin de |
|----|-------------|---------|---------|
| US-01 | Citoyen | Voir un splash puis l’onboarding | Comprendre la valeur de l’app |
| US-02 | Citoyen | Me connecter avec mon téléphone | Accéder au service sans friction |
| US-03 | Citoyen | Autoriser la géolocalisation | Obtenir des résultats pertinents |
| US-04 | Citoyen | Voir la liste des pharmacies de garde proches | Choisir où me rendre |
| US-05 | Citoyen | Rechercher une pharmacie | Retrouver un établissement |
| US-06 | Citoyen | Ouvrir la fiche détail | Voir contacts, horaires, assurances, note |
| US-07 | Citoyen | Appeler / ouvrir l’itinéraire | Agir immédiatement |
| US-08 | Citoyen | Noter et commenter | Partager mon expérience |
| US-09 | Citoyen | Signaler une garde incorrecte | Améliorer la fiabilité |
| US-10 | Citoyen | Consulter les numéros d’urgence | Obtenir de l’aide alternative |
| US-11 | Citoyen | Accéder aux réglages / aide / about | Personnaliser et s’informer |

## Parcours nominaux

### P1 — Première ouverture

```
Splash → Onboarding → Login (phone)
  → (si nouveau) capture position → POST /clients
  → Home (nearest-duty)
```

### P2 — Retour utilisateur

```
Splash → lecture cache auth → Home
```

### P3 — Signalement

```
Home / Détail → reportDutyIssue → API duty/report → feedback UI
```

## Règles fonctionnelles

- Session locale : `cached_auth_response` (SharedPreferences).
- Une review max par couple (client, pharmacie) côté backend.
- Pas de carte in-app : navigation via apps Maps système.
- Urgences : lecture cache si offline lorsque disponible.

## Écrans

| Écran | Feature |
|-------|---------|
| Splash | `splash` |
| Onboarding | `onboarding` |
| Login | `auth` |
| Home | `home` + pharmacy notifiers |
| Détail pharmacie | `pharmacy` |
| Urgences | `emergency` |
| Settings / Help / About | features homonymes |
