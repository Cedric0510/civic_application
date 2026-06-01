# City-Co — Application mobile citoyenne

City-Co est une application Flutter destinée aux citoyens de communes françaises. Elle permet de consulter les actualités locales, participer aux sondages municipaux, prendre des rendez-vous en mairie, découvrir les services de la commune, et gérer son profil. Elle est connectée à un backend Supabase et administrée via une interface web séparée.

---

## Sommaire

- [Aperçu](#aperçu)
- [Stack technique](#stack-technique)
- [Installation et configuration](#installation-et-configuration)
- [Architecture du projet](#architecture-du-projet)
- [Référence technique — pages et widgets](#référence-technique--pages-et-widgets)
- [Fonctionnement de l'app — feature par feature](#fonctionnement-de-lapp--feature-par-feature)
- [Base de données Supabase](#base-de-données-supabase)

---

## Aperçu

| Authentification | Accueil | Actualités | Sondages |
|---|---|---|---|
| Connexion / inscription avec email et mot de passe | Carrousel d'articles, tuiles de navigation, météo locale | Liste des articles avec pull-to-refresh | Vote sur les sondages actifs |

| Rendez-vous | Services | Mon compte |
|---|---|---|
| Formulaire de prise de RDV en mairie | Annuaire des services municipaux | Profil, ville préférée, mes RDV, déconnexion |

---

## Stack technique

| Élément | Choix |
|---|---|
| Framework | Flutter 3.x — Dart 3.x |
| État | flutter_riverpod ^2.6.1 |
| Backend | Supabase (Auth + PostgreSQL + RLS) |
| Navigation | go_router ^14.8.1 |
| Requêtes HTTP | http ^1.3.0 (météo) |
| Variables d'env | flutter_dotenv ^5.2.1 |
| Égalité d'entités | equatable ^2.0.7 |
| Formatage dates | intl ^0.20.2 |
| Icônes launcher | flutter_launcher_icons ^0.14.3 |

---

## Installation et configuration

### Prérequis

- Flutter SDK >= 3.10.4
- Un projet Supabase actif
- Dart SDK >= 3.10.4

### Étapes

```bash
# 1. Cloner le dépôt
git clone https://github.com/Cedric0510/civic_application.git
cd civic_application

# 2. Installer les dépendances
flutter pub get

# 3. Créer le fichier d'environnement
touch .env
```

Contenu du fichier `.env` à la racine :

```
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

```bash
# 4. Lancer l'application
flutter run
```

---

## Architecture du projet

L'application suit la **Clean Architecture** par feature. Chaque feature est un module indépendant organisé en trois couches.

```
lib/
├── core/
│   ├── constants/        # Noms des tables Supabase
│   ├── errors/           # Hiérarchie d'exceptions (AppException)
│   ├── providers/        # Providers globaux (Supabase client, auth stream)
│   ├── routing/          # GoRouter + auth guard
│   └── theme/            # ThemeData de l'application
│
├── features/
│   ├── auth/             # Connexion / inscription
│   ├── home/             # Page d'accueil
│   ├── articles/         # Actualités (liste + détail)
│   ├── appointments/     # Prise de rendez-vous
│   ├── polls/            # Sondages
│   ├── services/         # Services municipaux
│   ├── account/          # Gestion du compte utilisateur
│   └── weather/          # Widget météo
│
└── shared/
    └── widgets/          # Widgets réutilisables (ErrorRetryWidget)
```

Chaque feature respecte la structure :

```
feature/
├── domain/
│   ├── entities/         # Objets métier purs (pas de dépendance Flutter)
│   ├── repositories/     # Contrats abstraits
│   └── usecases/         # Un fichier = une action métier
├── data/
│   ├── datasources/      # Appels Supabase
│   ├── models/           # Sérialisation JSON (étendent les entités)
│   └── repositories/     # Implémentations concrètes
└── presentation/
    ├── controllers/      # Riverpod : NotifierProvider, FutureProvider, DI
    ├── pages/            # Écrans (une page = un fichier)
    └── widgets/          # Widgets privés à la feature
```

### Principes appliqués

- Zéro commentaire dans le code — le code est auto-documenté
- Tous les identifiants en anglais, l'interface utilisateur en français
- `final` et `const` systématiques
- `autoDispose` sur tous les providers scoped à une page
- Pas de `Color.withOpacity` — utilisation exclusive de `withValues(alpha:)`
- `flutter analyze` : **0 warning, 0 erreur** en permanence

---

## Référence technique — pages et widgets

### Navigation — `core/routing/app_router.dart`

Le router est un `Provider<GoRouter>`. Il écoute `authStateProvider` (un `StreamProvider<User?>`) via un `ChangeNotifier` interne pour déclencher les redirections automatiquement.

| Route | Page | Guard |
|---|---|---|
| `/auth` | `AuthPage` | Redirige vers `/home` si connecté |
| `/home` | `HomePage` | Redirige vers `/auth` si non connecté |
| `/articles` | `ArticlesPage` | Auth requis |
| `/articles/:id` | `ArticleDetailPage` | Auth requis |
| `/appointments` | `AppointmentPage` | Auth requis |
| `/polls` | `PollsPage` | Auth requis |
| `/services` | `ServicesPage` | Auth requis |
| `/account` | `AccountPage` | Auth requis |

---

### Feature : Authentification — `features/auth/`

**Page :** `AuthPage`
- Affiche le logo City-Co, un formulaire email/mot de passe, et bascule entre mode connexion et inscription.
- Lit l'état via `authControllerProvider` (`StateNotifierProvider<AuthController, AsyncValue<void>>`).

**Controller :** `AuthController extends StateNotifier<AsyncValue<void>>`
- Méthodes : `signIn()`, `signUp()`, `signOut()`
- Utilise `SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`

**Providers DI :** `auth_providers.dart`
- `authDatasourceProvider` → `authRepositoryProvider` → use case providers

---

### Feature : Accueil — `features/home/`

**Page :** `HomePage`
- AppBar avec titre "City-Co" et icône de compte (`Icons.account_circle_outlined`) → `/account`
- Corps scrollable avec 4 widgets empilés verticalement

| Widget | Rôle | Provider consommé |
|---|---|---|
| `ArticlesCarousel` | Carrousel horizontal des 5 derniers articles | `articlesControllerProvider` |
| `VillageNameWidget` | Affiche le nom de la commune depuis Supabase | `settingsProvider` |
| `NavigationTilesGrid` | Grille 2×2 de tuiles colorées vers les features | Aucun (navigation pure) |
| `WeatherSection` | Encapsule `WeatherWidget` — météo via API HTTP | `weatherProvider` |

**Tuiles de navigation :**

| Tuile | Couleur | Route |
|---|---|---|
| Actualités | `#1E88E5` (bleu) | `/articles` |
| Rendez-vous | `#E53935` (rouge) | `/appointments` |
| Sondages | `#43A047` (vert) | `/polls` |
| Services | `#FB8C00` (orange) | `/services` |

---

### Feature : Actualités — `features/articles/`

**Pages :**
- `ArticlesPage` — liste de tous les articles, pull-to-refresh via `ref.invalidate(articlesControllerProvider)`
- `ArticleDetailPage` — détail d'un article chargé par son `id` via `articleDetailProvider(articleId)`

**Widgets :**
- `ArticleCard` — carte cliquable affichant titre, date, et image de couverture

**Controller :** `ArticlesController extends AsyncNotifier<List<Article>>`
- Provider : `articlesControllerProvider` (non autoDispose — partagé avec le carrousel de l'accueil)

**Provider notable :** `articleDetailProvider` — `FutureProvider.family<Article, String>` — chargement d'un article par son UUID

---

### Feature : Rendez-vous — `features/appointments/`

**Page :** `AppointmentPage`
- Contient uniquement un `AppointmentForm` dans un `SliverToBoxAdapter`

**Widgets :**
- `AppointmentForm` — formulaire complet : nom, email, service (dropdown), date (date picker), message optionnel
- `ServiceDropdown` — liste déroulante des services disponibles

**Controller :** `AppointmentController extends StateNotifier<AsyncValue<void>>`
- Méthode : `createAppointment(Appointment)` → `CreateAppointmentUseCase`
- Affiche un snackbar de succès et remet le formulaire à zéro après soumission

---

### Feature : Sondages — `features/polls/`

**Page :** `PollsPage`
- Liste des sondages actifs, pull-to-refresh via `ref.invalidate(pollsControllerProvider)`

**Widgets :**
- `PollCard` — carte d'un sondage avec ses options. Affiche le formulaire de vote si l'utilisateur n'a pas encore voté, ou les résultats s'il a déjà voté.
- `PollOptionTile` — une option cliquable avec état sélectionné
- `PollResultBar` — barre de progression affichant le pourcentage de votes d'une option

**Controller :** `PollsController extends AsyncNotifier<List<Poll>>`
- Au chargement : récupère les sondages actifs ET les votes de l'utilisateur en parallèle
- Méthode : `submitVote(pollId, optionId)` — mise à jour optimiste locale + appel Supabase + `invalidateSelf()`
- `votedPollsProvider` — `StateProvider<Map<String, String>>` — map `pollId → optionId` des votes de la session

---

### Feature : Services — `features/services/`

**Page :** `ServicesPage`
- Liste des services municipaux, pull-to-refresh via `ref.invalidate(servicesControllerProvider)`
- Triés par catégorie puis par nom (ordre défini côté Supabase)

**Widgets :**
- `ServiceCard` — carte d'un service avec nom, catégorie, téléphone, adresse, horaires

**Controller :** `ServicesController extends AutoDisposeAsyncNotifier<List<Service>>`

---

### Feature : Mon compte — `features/account/`

**Page :** `AccountPage` — `ConsumerStatefulWidget`
- Pull-to-refresh : invalide `userProfileProvider` + `userAppointmentsProvider`
- SliverAppBar violet (`#5E35B1`)

**Widgets internes (privés à la page) :**

| Widget | Rôle |
|---|---|
| `_UserInfoSection` | Avatar + email de l'utilisateur connecté |
| `_CitySection` | Champ texte pour saisir/modifier sa ville préférée |
| `_AppointmentsSection` | Liste des RDV de l'utilisateur via `userAppointmentsProvider` |
| `_DangerSection` | Boutons "Se déconnecter" et "Supprimer mon compte" (avec dialog de confirmation) |

**Widget partagé :** `AccountAppointmentCard` — carte d'un rendez-vous (service, date, message)

**Providers :**
- `userProfileProvider` — `FutureProvider.autoDispose<UserProfile?>` — profil Supabase
- `userAppointmentsProvider` — `FutureProvider.autoDispose<List<Appointment>>` — filtre par email de l'utilisateur connecté

**Controller :** `AccountController extends StateNotifier<AsyncValue<void>>`
- Méthodes : `updateCity(String)`, `deleteAccount()`
- `deleteAccount()` appelle la RPC Supabase `delete_user()` puis déconnecte

---

### Shared — `shared/widgets/`

**`ErrorRetryWidget`** — widget d'état d'erreur uniforme utilisé sur toutes les pages
- Icône nuage barré, message contextuel, bouton "Réessayer"
- `onRetry` : callback — dans tous les cas c'est un `ref.invalidate(provider)`

---

## Fonctionnement de l'app — feature par feature

### Authentification

1. Au lancement, `GoRouter` vérifie `authStateProvider`. Si l'utilisateur n'est pas connecté, il est redirigé vers `/auth`.
2. Sur `AuthPage`, il peut se connecter avec email/mot de passe ou créer un compte.
3. Dès que Supabase confirme la session, `authStateProvider` émet un nouvel état, le router réagit automatiquement et redirige vers `/home`.
4. La déconnexion peut se faire depuis la page Mon compte — même mécanique en sens inverse.

### Accueil

1. La page se compose de 4 blocs : le carrousel des dernières actualités (3 à 5 articles), le nom de la commune, les 4 tuiles de navigation, et le widget météo.
2. Le nom de la commune est lu depuis la table `settings` (une seule ligne, contrainte `id = 1`).
3. La météo est chargée via une API HTTP publique.
4. Chaque tuile navigue vers la feature correspondante.

### Actualités

1. `ArticlesPage` charge la liste depuis Supabase, triée par date de publication décroissante.
2. L'utilisateur peut tirer vers le bas pour rafraîchir.
3. En cas d'erreur réseau, `ErrorRetryWidget` propose de réessayer.
4. Un tap sur une carte navigue vers `/articles/:id` — `ArticleDetailPage` charge l'article complet par son UUID.

### Rendez-vous

1. L'utilisateur remplit le formulaire : nom, email, service (dropdown), date (date picker natif), message optionnel.
2. La validation est faite côté formulaire avant soumission.
3. En cas de succès, un snackbar confirme la prise de RDV et le formulaire se réinitialise.
4. Les rendez-vous sont stockés en base avec l'email de l'utilisateur comme identifiant (retrouvables depuis la page Mon compte).

### Sondages

1. `PollsPage` charge tous les sondages actifs (`is_active = true`) avec leurs options.
2. En parallèle, les votes de l'utilisateur sont chargés depuis `poll_votes` (filtrés par `user_id`).
3. Si l'utilisateur n'a pas encore voté sur un sondage, `PollCard` affiche les options cliquables.
4. Si l'utilisateur a déjà voté, `PollCard` affiche les résultats sous forme de barres de progression (`PollResultBar`) avec les pourcentages.
5. Le vote est optimiste : l'UI se met à jour immédiatement avant la confirmation Supabase. Une contrainte unique `(user_id, poll_id)` en base empêche les doubles votes.

### Services

1. `ServicesPage` charge la liste depuis la table `services`, triée par catégorie puis par nom.
2. Chaque `ServiceCard` affiche les informations disponibles : nom, catégorie (badge), description, numéro de téléphone, adresse, horaires.
3. Les champs optionnels (phone, address, hours, description) ne s'affichent que s'ils sont renseignés.

### Mon compte

1. La page charge en parallèle le profil utilisateur (`user_profiles`) et ses rendez-vous.
2. **Ma ville** : champ texte pré-rempli avec la valeur en base. Un tap sur "Enregistrer" (ou validation du clavier) fait un `upsert` sur `user_profiles`.
3. **Mes rendez-vous** : liste des RDV filtrée par l'email de l'utilisateur connecté, du plus récent au plus ancien.
4. **Se déconnecter** : appelle `AuthController.signOut()` — le router redirige automatiquement vers `/auth`.
5. **Supprimer mon compte** : dialog de confirmation, puis appel de la RPC `delete_user()` qui supprime l'entrée dans `auth.users` (cascade sur `user_profiles`), suivi d'un `signOut()`.

---

## Base de données Supabase

### Tables

| Table | Description | RLS |
|---|---|---|
| `articles` | Actualités publiées par l'administration | Lecture publique |
| `settings` | Paramètres globaux (nom de la commune) — une seule ligne | Lecture publique |
| `polls` | Sondages municipaux | Lecture publique |
| `poll_options` | Options de réponse d'un sondage | Lecture publique |
| `poll_votes` | Votes des utilisateurs — contrainte unique `(user_id, poll_id)` | Lecture/écriture authentifié |
| `appointments` | Rendez-vous pris en mairie | Insert public, lecture par email |
| `services` | Services municipaux | Lecture publique |
| `user_profiles` | Profil utilisateur (ville préférée) | Lecture/écriture propriétaire uniquement |

### Fonctions

| Fonction | Description |
|---|---|
| `delete_user()` | RPC `security definer` — supprime l'utilisateur courant de `auth.users` |

---

