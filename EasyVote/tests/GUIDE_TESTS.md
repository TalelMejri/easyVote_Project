# Guide d'exécution des tests — EasyVote

Équipe : Talel Mejri · Rawen Zgarni · Issra Elakrout

Ce guide explique comment **lancer le projet** puis **exécuter chaque famille de tests**
(automatisés et manuels), et où retrouver les résultats pour le rapport.

---

## 0. Ce qui a été ajouté au projet

| Fichier | Rôle |
|---|---|
| `easyvote-backend/src/test/java/.../boitenoire/` | 12 tests boîte noire (4 techniques × 3) |
| `easyvote-backend/src/test/java/.../boiteblanche/` | 15 tests boîte blanche (5 techniques × 3) |
| `easyvote-backend/src/test/java/.../unitaire/ChatbotRulesTest.java` | 3 tests unitaires (dont 1 non-fonctionnel) |
| `easyvote-backend/src/test/java/.../integration/ApiIntegrationTest.java` | 3 tests d'intégration (API + sécurité + BDD H2) |
| `easyvote-backend/src/test/resources/application-test.properties` | Profil de test : base H2 en mémoire |
| `easyvote-backend/pom.xml` | + H2 (test), + JaCoCo (couverture), Surefire en mode campagne |
| `tests/system-tests.mjs` | Tests système E2E automatisés (vraie API) |
| `tests/seed-demo.sql` | Comptes de test du README (mot de passe `password123`) |
| `tests/lancer-tests.ps1` | Lance tous les tests JUnit en une commande |
| `tests/postman/EasyVote.postman_collection.json` | 3 tests d'API Postman (login, `/auth/me`, accès refusé) |
| `tests/sonar-analyse.ps1` | Analyse statique SonarQube (Docker, port 9000) |
| `tests/jmeter/EasyVote-charge.jmx` + `tests/jmeter-charge.ps1` | Test de charge JMeter |
| `tests/exploratoire.mjs`, `tests/maintenance-sauvegarde.ps1` | Tests exploratoires et de maintenance |

---

## 1. Lancer le projet

### 1.1 Base de données
1. Ouvrir **XAMPP Control Panel** → *Start* sur **MySQL** (Apache n'est pas nécessaire).
2. Si la base `easyvote_db` n'existe pas : phpMyAdmin → *New* → `easyvote_db` (utf8mb4).
3. Démarrer une première fois le backend (étape 1.2) pour que Hibernate crée les tables, puis charger les comptes :
   ```powershell
   C:\xampp\mysql\bin\mysql.exe -uroot easyvote_db -e "source tests/seed-demo.sql"
   ```
   Comptes : `ahmed@test.com` (ADMIN), `achref@`, `dali@`, `moez@`, `talel@test.com` (STUDENT) — mot de passe `password123`.

### 1.2 Backend (port 8082)
> ⚠️ Sur le PC de Talel, le port **8082 est occupé** par un conteneur Docker `web` (nginx).
> Le libérer avec `docker stop web`, ou lancer le backend sur un autre port (voir plus bas).

> ⚠️ Utiliser **Java 21** (Java 25 est installé mais Lombok du projet ne le supporte pas).

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21.0.11"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
cd easyvote-backend
mvn spring-boot:run
# si "mvn" n'est pas reconnu, utiliser le Maven en cache :
# & "$env:USERPROFILE\.m2\wrapper\dists\apache-maven-3.8.6-bin\1ks0nkde5v1pk9vtc31i9d0lcd\apache-maven-3.8.6\bin\mvn.cmd" spring-boot:run
```
Autre port : `mvn spring-boot:run "-Dspring-boot.run.arguments=--server.port=8084"`.

### 1.3 Frontend (port 5173)
```powershell
cd easyvote-frontend
npm install          # une seule fois
npm run dev
```
Si le backend n'est pas sur 8082 : `$env:VITE_API_URL="http://localhost:8084/api"; npm run dev`.
Ouvrir http://localhost:5173.

---

## 2. Tests automatisés JUnit (unitaires, boîte noire, boîte blanche, intégration)

```powershell
.\tests\lancer-tests.ps1                # les 33 tests
.\tests\lancer-tests.ps1 boitenoire     # ou : boiteblanche, unitaire, integration
.\tests\lancer-tests.ps1 McdcPeriodeVoteTest   # une seule classe
```
Chaque test s'affiche avec sa phrase descriptive et [OK] / [ECHEC] (+ la raison de l'échec).
Pas besoin de XAMPP : les tests d'intégration utilisent une base **H2 en mémoire**.

**Résultat attendu aujourd'hui : 33 tests, 30 réussis, 3 échecs.**
Les 3 échecs sont **voulus** : ce sont des défauts réels du code (DEF-00, DEF-01, DEF-04, voir §7).
Un test qui échoue parce que le logiciel ne respecte pas le cahier des charges = le test a fait son travail.

Résultats :
- détail par test : `easyvote-backend/target/surefire-reports/*.txt`
- **couverture de code** : ouvrir `easyvote-backend/target/site/jacoco/index.html` dans le navigateur
  (capture d'écran pour le rapport → preuve de la couverture boîte blanche).

### Ce que teste chaque classe

| Classe | Technique | Les 3 cas |
|---|---|---|
| `PartitionEquivalenceOtpTest` | BN — partition d'équivalence | `123456` ✔ · `12345` ✘ · `12AB56` ✘ |
| `ValeursLimitesCandidatureTest` | BN — valeurs limites | slogan 200 ✔ · slogan 201 ✘ · photo 5 Mo ✔ (**échoue → DEF-01**) |
| `TableDecisionVoteTest` | BN — table de décision | R1 (V,V) vote · R2 élection fermée · R3 déjà voté |
| `TransitionEtatElectionTest` | BN — transition d'état | DRAFT→CAMPAIGN ✔ · CAMPAIGN→VOTE ✔ · DRAFT→VOTE ✘ |
| `CouvertureInstructionsHashTest` | BB — instructions | vecteur NIST SHA-256 · format 64 hex · jetons uniques |
| `CouvertureBranchesTokensTest` | BB — branches | élection absente · idempotence · génération |
| `CouvertureDecisionsConditionsTest` | BB — décisions | dates OK · campagne nulle · vote inversé |
| `ComplexiteCyclomatiqueVoteTest` | BB — chemins indépendants, V(G)=12 | non vérifié · autre élection · jeton à la volée |
| `McdcPeriodeVoteTest` | BB — MC/DC (A && B) | (V,V) · (V,F) · (F,-) |
| `ChatbotRulesTest` | Unitaire fonct. + non-fonct. | « Bonjour » · < 50 ms · « devenir candidat » (**échoue → DEF-04**) |
| `ApiIntegrationTest` | Intégration | inscription+OTP · RBAC 401/403 · vote anonyme (**échoue → DEF-00**) |

---

## 3. Tests système automatisés (E2E)

Backend + MySQL démarrés, seed chargé :
```powershell
node tests/system-tests.mjs
# autre port :  $env:API_URL="http://localhost:8084/api"; node tests/system-tests.mjs
```
Le script joue le scénario de démo du CDC §7.3 sur la **vraie** application :
ST-01 (création → candidature → validation → vote → résultats), ST-02 (double vote refusé),
ST-03 (transparence pendant/après vote), ST-05 (PDF), ST-NF (GET /elections < 200 ms).
**Résultat obtenu : 12/12 vérifications réussies.** Chaque exécution crée une nouvelle élection (re-jouable).

---

## 4. Tests manuels

### 4.1 Vérification SQL de l'anonymat (à faire après un vote)
Dans phpMyAdmin → `easyvote_db` → SQL :
```sql
SHOW COLUMNS FROM votes;            -- attendu : pas de user_id  → OK
SELECT u.email AS electeur, cu.full_name AS a_vote_pour
FROM votes v
JOIN vote_tokens t ON t.token_hash = v.token_hash
JOIN users u  ON u.id = t.user_id
JOIN candidates c ON c.id = v.candidate_id
JOIN users cu ON cu.id = c.user_id;  -- attendu : 0 ligne. OBTENU : le vote de chaque étudiant → DEF-00
```
Faire une capture d'écran du résultat : c'est la preuve la plus forte du rapport.

### 4.2 Tests exploratoires — `node tests/exploratoire.mjs`
| # | Action | Attendu (CDC) | Obtenu |
|---|---|---|---|
| EX-1 | Postuler à une élection en **DRAFT** | refus (§3.1.2 : CAMPAIGN_ACTIVE seulement) | accepté (201) → DEF-03 |
| EX-2 | Consulter `/api/auth/me` après candidature PENDING | rôle STUDENT | CANDIDATE → DEF-02 |
| EX-3 | Voter avec le compte **admin** | refus (§6.1 « Ne vote pas ») | vote accepté → DEF-05 |

### 4.3 Tests d'acceptation (UAT) — à exécuter dans le navigateur
Chaque membre joue un rôle ; noter OK/KO et une note de 1 à 5 sur la facilité.

**UAT-01 — Étudiant (Rawen)** : connexion `talel@test.com` → *Élections* → ouvrir l'élection en vote →
lire un programme → *Voter* → cocher « Je comprends que mon vote est définitif » → confirmer.
*Attendu* : code de confirmation à 10 caractères affiché ; le bouton *Voter* disparaît ; les résultats détaillés ne sont pas visibles avant la clôture.

**UAT-02 — Candidat (Issra)** : connexion `achref@test.com` → *Ma campagne* → modifier le programme →
publier une annonce → répondre à une question posée par un autre étudiant.
*Attendu* : l'annonce apparaît sur le profil public ; l'auteur de la question reçoit une notification (cloche).

**UAT-03 — Administrateur (Talel)** : connexion `ahmed@test.com` → créer une élection →
passer en campagne → valider une candidature → ouvrir le vote → clôturer → télécharger le PDF.
*Attendu* : chaque étape est compréhensible sans aide ; le PDF contient titre, période, votants, taux, classement.

---

## 5. Tests statiques

### 5.1 Analyse statique outillée
```powershell
cd easyvote-frontend
npx eslint .        # obtenu : 64 erreurs, 5 warnings (dont 4 "rules-of-hooks" → DEF-07)
npx tsc -b          # obtenu : 0 erreur de typage
npm audit           # obtenu : 35 vulnérabilités de dépendances (1 critique, 26 hautes)
```

### 5.2 Revue technique (checklist appliquée au code)
| Point de contrôle | Fichier | Constat |
|---|---|---|
| Durée du jeton d'accès = 1 h (CDC 4.4.1) | `application.properties` | `easyvote.jwt.expiration=86400000` = **24 h** → DEF-06 |
| Aucun secret dans le dépôt | `application.properties` | identifiants Mailtrap en clair → à externaliser |
| Formats photo JPG/PNG uniquement | `PhotoUploadService` | accepte tout `image/*` (GIF, WebP…) |
| Notification en cas de rejet (CDC 3.3.2) | `CandidateService.validateCandidate` | seule la validation notifie |

---

## 5 bis. SonarQube, JMeter et Postman

```powershell
.\tests\sonar-analyse.ps1               # SonarQube : http://localhost:9000/dashboard?id=easyvote
.\tests\jmeter-charge.ps1 -Users 200    # JMeter : rapport HTML dans tests\jmeter\rapport\index.html
npx newman run tests/postman/EasyVote.postman_collection.json   # Postman en ligne de commande
```
Résultats obtenus : SonarQube → 0 vulnérabilité, 3 bugs (faux positifs), 44 code smells, couverture 25,6 % ;
JMeter → 0 % d'erreur jusqu'à 200 utilisateurs, 52 % des requêtes > 200 ms à 500 utilisateurs (DEF-08) ;
Postman → 9 vérifications sur 9.

---

## 6. Saisie dans Testiny (projet « easyvote »)

1. Les 68 cas du plan sont déjà rangés en 4 dossiers : Unitaire, Intégration, Système (E2E), Acceptation (UAT).
2. Ajouter les tests exécutés absents du plan (PE, VL, R, B, DC, CC, T, PM-01..03, EX-1..3, JWT-01, SQL-01, MT-01/02),
   en gardant leur identifiant dans le titre et l'exigence couverte (EX-xx) dans la description.
3. **Create test run** (un par dossier) → marquer chaque cas *Passed* / *Failed* selon les résultats de ce guide.
4. Pour chaque *Failed* : noter le défaut (DEF-xx) dans le résultat.
5. Captures d'écran : la liste des cas, un test run avec ses résultats → à mettre dans le rapport.

---

## 7. Défauts détectés

| ID | Gravité | Description | Détecté par |
|---|---|---|---|
| DEF-00 | **Critique** | Le vote est ré-identifiable : `votes.token_hash` = `vote_tokens.token_hash` qui contient `user_id` | IT-04 (intégration) + SQL manuel |
| DEF-05 | Majeure | L'administrateur peut voter | Exploratoire EX-3 |
| DEF-06 | Majeure | Jeton d'accès valide 24 h au lieu de 1 h | Revue technique |
| DEF-02 | Majeure | Rôle CANDIDATE attribué au dépôt, avant validation | Exploratoire EX-2 |
| DEF-03 | Majeure | Candidature acceptée sur une élection DRAFT | Exploratoire EX-1 |
| DEF-01 | Mineure | Photo de 5 Mo exactement rejetée (limite codée à 5 000 000 octets) | VL-03 (valeurs limites) |
| DEF-04 | Mineure | « Comment devenir candidat ? » → mauvaise réponse du chatbot | UT-CB3 |
| DEF-08 | Majeure | Temps de réponse > 200 ms pour 52 % des requêtes à 500 utilisateurs | JMeter (ST-08) |
| DEF-07 | Mineure (latent) | Hooks React appelés après un `return` conditionnel (`ChatbotWidget.tsx:168`) | ESLint |

### Tests de régression
Après chaque correction : relancer **`.\tests\lancer-tests.ps1`** puis **`node tests/system-tests.mjs`**.
Le test qui échouait doit passer, et tous les autres doivent rester verts (non-régression).
