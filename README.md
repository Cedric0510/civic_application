# City-Co — application mobile

Application Flutter des citoyens d'une commune française. Elle se connecte à `civic_api` et affiche le contenu de la commune du citoyen.

## Fonctionnalités

- **Compte** : inscription en choisissant sa commune, connexion, changement de commune, suppression du compte. Une commune non partenaire est signalée à l'utilisateur.
- **Accueil** : actualités récentes et météo du jour ; toucher la carte météo ouvre le prévisionnel heure par heure.
- **Actualités**, **Services** (téléphone et e-mail cliquables), **Commerçants** (idem).
- **Sondages** : un vote par sondage, possible une semaine après l'arrivée dans une commune.
- **Rendez-vous** : choix d'un service, puis d'un jour et d'une heure parmi les créneaux réellement libres des agents.
- **Signalements** : adresse, catégorie, description et photo ; le signalement est rattaché au compte de son auteur.
- **Commerçant** : un compte associé à un commerce en gère lui-même la fiche (horaires, photos, notes).

## Démarrage local

`civic_api` doit tourner (voir son README).

```bash
cp .env.example .env     # API_BASE_URL selon la cible, voir ci-dessous
flutter pub get
flutter run
```

| Cible | `API_BASE_URL` |
|---|---|
| Émulateur Android | `http://10.0.2.2:4000` |
| Web ou bureau | `http://localhost:4000` |
| Téléphone physique | `http://<IP du poste>:4000`, sur le même réseau |

Tests : `flutter test` ; analyse : `dart analyze`.

## Architecture

Une couche par feature (`lib/features/<feature>/`), dans l'esprit d'une architecture propre :

```
domain/        entités, contrats de repository, cas d'usage
data/          modèles (JSON), sources de données HTTP, implémentations de repository
presentation/  contrôleurs Riverpod, pages, widgets
```

- `lib/core/` : client HTTP (`ApiClient`), stockage sécurisé du jeton, routage `go_router`, thème, erreurs.
- `lib/shared/` : widgets et utilitaires communs à plusieurs features.
- **Session** : `authStateProvider` porte la commune, le rôle et le délai avant vote du citoyen connecté ; tous les contenus en dépendent et se rechargent quand la commune change.
- **Météo** : l'appli ne contacte jamais OpenWeatherMap, elle lit le cache renvoyé par `GET /communes/:slug`.
- Le jeton est conservé dans `flutter_secure_storage`.

## Pile technique

Flutter 3 / Dart 3, `flutter_riverpod`, `go_router`, `http`, `flutter_dotenv`, `flutter_secure_storage`, `image_picker`, `url_launcher`, `intl`.
