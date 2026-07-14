# 01 — Exigences métier (Business Requirements)

## Vision

Permettre à tout citoyen en Côte d’Ivoire de **trouver rapidement une pharmacie de garde proche**, d’obtenir les bons contacts, et de contribuer à la fiabilité des listes via avis et signalements.

## Problématique

Hors horaires d’ouverture, l’information « quelle pharmacie assure la garde » est fragmentée (annonces, PDF, bouche-à-oreille). Sur le terrain, GPS + téléphone doivent suffire pour décider en quelques secondes.

## Objectifs

| ID | Objectif | Critère de succès |
|----|----------|-------------------|
| O1 | Afficher les pharmacies de garde à proximité | Liste triée par distance depuis GPS |
| O2 | Fiche établissement actionable | Appel, itinéraire externe, assurances, horaires |
| O3 | Onboarding minimal | Login téléphone (+ geo à l’inscription) |
| O4 | Boucle qualité | Avis 1–5 + signalement « pas vraiment de garde » |
| O5 | Secours contextuel | Numéros d’urgence catégorisés, dispo hors-ligne partielle |
| O6 | UX rassurante | Splash, onboarding, thème lisible, aide / about |

## Périmètre

**Inclus** : app Flutter iOS/Android, consommation API `:8080`, géoloc device, deeplinks maps/tel.

**Exclu (état actuel)** : cartes embarquées, push FCM, auth sociale réelle, favoris persistés, paiement.

## Parties prenantes

| Acteur | Besoin |
|--------|--------|
| Citoyen | Trouver vite une garde fiable |
| Opérateur BO | Recevoir signalements / avis |
| Équipe mobile | Architecture évolutive (voir ADR-001) |

## Contraintes

- Flutter / Dart 3.4+.
- Réseau parfois faible → stratégie cache partielle.
- Base URL distincte émulateur Android (`10.0.2.2`) vs iOS (`localhost`).
