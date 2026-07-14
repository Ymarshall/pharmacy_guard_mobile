# Assets UI/UX — pharmacie_de_garde (Mobile)

## Identité (implémentée)

- Positionnement : « Trouvez votre pharmacie 24/7 ».
- Typo : `google_fonts`.
- Thème : `config/themes` (`app_theme.dart`, `colors.dart`).
- Navigation principale : Home + drawer (urgences, settings, help, about).

## Écrans à couvrir en design

| Écran | Priorité | Notes |
|-------|----------|-------|
| Splash | Haute | Brand entry |
| Onboarding (slides) | Haute | Valeur produit |
| Login téléphone | Critique | Permission geo à l’inscription |
| Home gardes | Critique | Liste + search |
| Fiche pharmacie | Critique | CTA appel / itinéraire / avis / signalement |
| Numéros d’urgence | Haute | Catégories |
| Settings / Help / About | Moyenne | Toggles notifs locaux non branchés |

## Figma / wireframes

- **Lien Figma Mobile** : _à renseigner_
- Déposer les exports dans ce dossier (`home.png`, `pharmacy_detail.png`, …).

## Guidelines UX

1. Premier viewport : marque + promesse + CTA clair (pas de dashboard dense).
2. Accès garde < 3 taps après login.
3. États vides / offline / permission GPS refusée explicitement.
4. Confirmation avant signalement.
5. Pas de carte in-app : deep link Maps natif.
