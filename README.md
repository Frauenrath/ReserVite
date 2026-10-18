# ReserVite – Système de Gestion & Réservation de Restaurants Sécurisé

## 📝 À quoi sert l'application ?
**ReserVite** est une solution logicielle d'entreprise complète (Full-Stack) dédiée à la gestion centralisée et à la réservation de tables de restaurants. L'application est articulée autour de deux profils d'utilisateurs authentifiés :
* **Les Clients :** Qui peuvent rechercher des restaurants par critères (ville, fourchette de prix), consulter les créneaux disponibles et planifier, modifier ou annuler leurs réservations.
* **Les Managers :** Qui supervisent les établissements qui leur sont assignés, valident les demandes en attente (*pending*) et y assignent physiquement les tables.

Le cœur de ce projet repose sur une architecture **"Database-First"** et **"Security by Design"** : 100 % des règles de calcul complexes (chevauchement des horaires, capacités maximales des tables, intégrité temporelle) et de l'étanchéité des données sont contrôlées et exécutées directement au niveau du serveur de base de données.

---

## 🚀 Fonctionnalités clés & Règles métier gérées

### 1. Moteur de Base de Données Avancé (PostgreSQL)
* **Intégrité transactionnelle stricte :** Implémentation de contraintes de vérification (*Check Constraints*), d'unicité (indépendante de la casse et après *trim*) et de clés étrangères pour interdire toute corruption de données.
* **Triggers de règles métier (BR-xx) :** Développement de déclencheurs automatiques pour automatiser les contrôles multicritères :
    * **BR-02 & BR-06 :** Blocage automatique si le nombre de convives dépasse la capacité cumulée des tables assignées, et interdiction de surréservation d'une table sur un même créneau.
    * **BR-04 & BR-05 :** Alignement dynamique et obligatoire des heures de réservation sur les créneaux propres du restaurant (10, 15, 20, 30 ou 60 min) et sur ses heures d'ouverture.
    * **BR-09 & BR-11 :** Gestion du cycle de vie immuable d'une réservation (`pending` → `confirmed` → `completed`/`cancelled`) avec verrouillage des données dès qu'un statut final est atteint.

### 2. API REST Étanche (PostgREST)
* **Architecture RPC (Remote Procedure Call) :** Sécurisation absolue de la couche réseau. L'API web ne donne accès qu'à des fonctions stockées PostgreSQL, masquant totalement la structure des tables sous-jacentes.
* **Contrôle d'accès à 3 niveaux :** Filtrage systématique des requêtes HTTP (GET/POST) validant l'authentification (jetons sécurisés), le rôle utilisateur (Client vs Manager) et le lien de propriété avec la ressource (un client ne peut lire ou modifier que ses propres réservations).

### 3. Interface Graphique Réactive (Flutter & Riverpod)
* **Gestion d'état centralisée :** Utilisation fine du framework **Riverpod** pour garantir une synchronisation immédiate et locale des listes et compteurs dès qu'une action de mutation (création, annulation) est validée.
* **Ergonomie métier :** Recherche dynamique avec système de pause (*Debounce*) pour soulager le serveur, notifications push en bas d'écran en cas d'erreur métier, et boîtes de dialogue de confirmation de sécurité.

---

## 🛠️ Technologies utilisées

* **Backend & Données :** PostgreSQL (Triggers, Fonctions PL/pgSQL, Types composites)
* **Couche API :** PostgREST (Mapping automatique des fonctions de base de données en terminaux REST)
* **Frontend Mobile/Desktop :** Dart, Flutter (Cible principale : Windows Desktop)
* **Gestion d'État :** Riverpod
* **Outils d'intégration & Tests :** IntelliJ REST Client (fichiers `.http`), BitBucket (Git), Postman (conception)

---

## 💻 Comment utiliser et lancer le projet ?

### 1. Déploiement du Backend (PostgreSQL)
1. Créez une base de données nommée conformément aux consignes académiques dans votre instance locale.
2. Exécutez les scripts d'initialisation de votre dossier `backend` dans l'ordre séquentiel strict pour monter la structure et charger les déclencheurs :
    * `01_init.sql` : Création du schéma et extensions.
    * `02_security.sql` : Configuration des rôles et hachage des mots de passe.
    * `03_tables_and_data.sql` : Schéma de données imposé et injection des jeux de tests.
    * `04.00_checks.sql` : Déploiement des contraintes de vérification (*Check*).
    * `04.xx_br_xxxx.sql` : Activation des triggers de sécurité métier.

### 2. Lancement de la couche API
1. Configurez et lancez votre instance **PostgREST** en la connectant à votre base de données locale.
2. Assurez-vous que l'API écoute bien sur l'URL de référence : `http://localhost:3000/`.
3. Vous pouvez utiliser le fichier `.http` inclus pour tester la validité des *endpoints* de lecture et d'écriture.

### 3. Exécution de l'application cliente (Flutter)
1. Assurez-vous de disposer du SDK Flutter configuré sur votre machine.
2. Récupérez les dépendances du projet depuis la racine de l'application :
   ```bash
   flutter pub get
   ```
3. Lancez la compilation de l'application sur la cible de test obligatoire (Windows Desktop) :
   ```bash
   flutter run -d windows
   ```

---

## 📋 Note de livraison & Données de test

Pour faciliter l'utilisation du projet, les features de débogage sont accessibles :



