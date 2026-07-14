# 06 — Glossaire — pharmacie_de_garde

| Terme | Définition |
|-------|------------|
| **Pharmacie de garde** | Établissement listé sur la période courante pour un service hors horaires. |
| **Nearest-duty** | Endpoint / écran listant les gardes les plus proches de l’utilisateur. |
| **Client** | Utilisateur mobile identifié surtout par numéro de téléphone. |
| **Clean Architecture** | Séparation domain / data / presentation pour isoler les règles métier. |
| **Repository** | Abstraction d’accès données (interface domain + impl data). |
| **DataSource** | Source concrète remote (HTTP) ou local (prefs / mémoire). |
| **Riverpod** | Bibliothèque Flutter de DI et d’état réactif utilisée comme composition root. |
| **StateNotifier** | Classe Riverpod mutualisant logique + état d’écran. |
| **Either / Failure** | Pattern `dartz` pour retourner succès ou erreur typée sans exception non contrôlée. |
| **Signalement** | Remontée utilisateur qu’une garde est incorrecte (`duty/report`). |
| **Avis / Review** | Note et commentaire sur une pharmacie. |
| **Onboarding** | Écrans d’introduction avant le premier login. |
| **Deep link Maps** | Ouverture de l’app cartes système via `url_launcher`. |
| **Cache mémoire** | Stockage volatile des pharmacies pour la session app (non durable). |
| **SharedPreferences** | Stockage clé-valeur local (session auth, urgences). |
| **NetworkInfo** | Service indiquant la connectivité avant un appel remote. |
