# 04 — Spécifications API (contrats consommés)

Client mobile consommateur de `pharmaciegarde`. OpenAPI de référence : `http://localhost:8080/api-docs`.

## Endpoints utilisés

### Auth & clients

| Méthode | Path | Usage app |
|---------|------|-----------|
| POST | `/auth/client/login` | Login téléphone `{ phone }` |
| POST | `/clients` | Création si inexistant (phone + lat/lng) |

### Pharmacies

| Méthode | Path | Usage app |
|---------|------|-----------|
| GET | `/client/pharmacies/nearest-duty` | Liste gardes proches (Home) |
| GET | `/client/pharmacies/nearest` | Proximité générale |
| GET | `/pharmacies` | Annuaire / recherche |
| POST | `/client/pharmacies/duty/report` | Signalement garde |

### Avis

| Méthode | Path | Usage app |
|---------|------|-----------|
| GET | `/client/pharmacies/{id}/reviews` | Liste |
| GET | `/client/pharmacies/{id}/rating-summary` | Synthèse |
| POST | `/client/pharmacies/{id}/reviews` | Création |
| PUT/DELETE | `.../reviews/{reviewId}` | Édition / suppression |

### Urgences

| Méthode | Path | Usage app |
|---------|------|-----------|
| GET | `/emergency-numbers` | Liste catégories |

## Payloads illustratifs

### Login

```json
{ "phone": "+2250700000000" }
```

### Signalement

```json
{
  "clientId": 12,
  "pharmacyId": 3,
  "message": "Pharmacie fermée malgré la liste de garde"
}
```

### Review (création)

```json
{
  "clientId": 12,
  "rating": 4,
  "comment": "Service rapide"
}
```

## Notes d’intégration

- Aucun header d’auth : l’identité est portée par `clientId` dans les body métier.
- Certaines méthodes datasource ont encore un fallback mock — la cible long terme est 100 % remote + cache.
- Timeout client : 30 secondes ; gérer UI loading / offline via `NetworkInfo`.
