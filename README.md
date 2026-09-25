# City-Co — application mobile

Application Flutter des citoyens d'une commune française. Elle se connecte à `civic_api` et affiche le contenu de la commune du citoyen.

## Fonctionnalités

- **Compte** : inscription en choisissant sa commune, connexion, changement de commune, suppression du compte. Une commune non partenaire est signalée à l'utilisateur. « Mot de passe oublié ? » sur la page de connexion : l'adresse e-mail du compte reçoit un code valable 30 minutes, à saisir avec le nouveau mot de passe (pas de lien, l'appli est le seul livrable citoyen). Toutes les sessions ouvertes sont alors fermées. Un futur commerçant invité par sa mairie touche « J'ai un code d'invitation commerçant » à l'inscription et saisit le code reçu par e-mail : son compte gère alors directement son commerce.
- **Accueil** : actualités récentes et météo du jour ; toucher la carte météo ouvre le prévisionnel heure par heure.
- **Actualités**, **Services** (téléphone et e-mail cliquables), **Commerçants** (idem).
- **Sondages** : un vote par sondage, possible une semaine après l'arrivée dans une commune.
- **Rendez-vous** : choix d'un service, puis d'un jour et d'une heure parmi les créneaux réellement libres des agents.
- **Signalements** : adresse, catégorie, description et photo ; le signalement est rattaché au compte de son auteur.
- **Commerçant** : un compte associé à un commerce en gère lui-même la fiche (horaires, photos, notes).
- **Avis** : depuis l'accueil ou « Mon compte », une note de 1 à 5, un type (problème, idée, autre) et un message, lus par la mairie et par l'équipe City-Co. L'adresse e-mail n'est visible que si l'habitant l'autorise.
- **Données et textes légaux** : « Mon compte » permet de recevoir ses données par e-mail (fichier JSON) et de lire les mentions légales et la politique de confidentialité de sa commune, éditables par la mairie. L'inscription demande de les accepter ; les textes sont lisibles avant de créer le compte, une fois la commune choisie.

## Accessibilité

- **Mode Confort** : un interrupteur sur la page de connexion, dans « Mon compte » et un bouton sur l'accueil. Il agrandit tous les textes d'au moins 30 % (en s'ajoutant au réglage du téléphone, plafonné à 200 %), renforce les contrastes (niveau AAA), épaissit les bordures des champs, agrandit les boutons (60 px de haut) et passe les tuiles de l'accueil sur une colonne. Le choix est mémorisé. Le nom et sa description sont définis à un seul endroit (`display_settings.dart`).
- **Réglage du téléphone respecté** : sans Mode Confort, la taille de texte du système s'applique ; à partir de 130 %, les tuiles de l'accueil passent aussi sur une colonne.
- **Lecteurs d'écran** : titres de page et de section déclarés comme titres, boutons icônes nommés (retour, afficher le mot de passe, retirer la photo), notes en étoiles annoncées « 4 étoiles sur 5 », images décoratives ignorées, indicateurs de chargement nommés, interface en français (`Locale('fr')`).
- **Contraste** : les couleurs des rubriques (`FeatureColors`) portent du texte blanc à 4,5:1 au moins ; un test le garantit.
- **Mouvement** : les animations du carrousel se coupent quand le système demande de réduire les animations.
- Des tests parcourent les pages principales à 100 % et 200 % de taille de texte, en affichage normal et en Mode Confort : aucun débordement, chaque commande nommée et d'au moins 48 px.

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

## Tester sur un téléphone

1. Brancher le téléphone (débogage USB activé) ou l'associer en Wi-Fi, puis vérifier `flutter devices`.
2. Dans `.env`, remplacer `API_BASE_URL` par l'adresse du PC sur le réseau local, par exemple `http://192.168.1.20:4000` (l'émulateur Android utilise `http://10.0.2.2:4000`).
3. Autoriser le port 4000 dans le pare-feu Windows (réseau privé), lancer l'API, puis `flutter run`.

Les versions debug et profile acceptent le HTTP en clair pour ce besoin ; la version release exige HTTPS.

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
- **Modules** : City-Co peut désactiver des modules pour une commune (`disabledModules` dans `GET /communes/:slug`). `disabledModulesProvider` alimente l'accueil (tuiles, actualités, météo), la page Compte et le routeur (`resolveRedirect` renvoie vers l'accueil une route de module désactivé) ; l'API reste l'arbitre et répond 403 sur ces routes. La liste se recharge quand l'appli revient au premier plan.
- Le jeton est conservé dans `flutter_secure_storage`.

## Pile technique

Flutter 3 / Dart 3, `flutter_riverpod`, `go_router`, `http`, `flutter_dotenv`, `flutter_secure_storage`, `image_picker`, `url_launcher`, `intl`.
