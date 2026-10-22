# Fiche des tests EasyVote — un tableau par exigence de l'atelier

> Toutes les commandes se lancent dans PowerShell, depuis le dossier `EasyVote`,
> avec **MySQL + backend (8082) + frontend (5173) démarrés**.

---

## ★ Les 4 outils demandés : JUnit, Postman, SonarQube, JMeter

| Outil | Rôle (type de test) | Commande | Résultat obtenu |
|---|---|---|---|
| **JUnit** (+ JaCoCo) | Tests unitaires et d'intégration, boîte noire et boîte blanche (fonctionnel, structurel) | `.\tests\lancer-tests.ps1` (ou `PE-01` pour un seul test) | 33 tests : 30 OK, 3 échecs = défauts DEF-00, 01, 04 |
| **Postman** | Tests d'API : connexion, `/auth/me`, sécurité 401 (fonctionnel + non fonctionnel) | Postman → Import `tests\postman\EasyVote.postman_collection.json` → *Run collection* (ou `npx newman run tests/postman/EasyVote.postman_collection.json`) | 9 vérifications sur 9 |
| **SonarQube** | Analyse **statique** du code : bugs, vulnérabilités, code smells, complexité, couverture | `.\tests\sonar-analyse.ps1` puis http://localhost:9000 (`admin` / `admin`) | 0 vulnérabilité, 3 bugs = faux positifs, 44 code smells, couverture 25,6 % |
| **JMeter** | Test de **charge / performance** (non fonctionnel, niveau système) | `.\tests\jmeter-charge.ps1 -Users 200` puis `tests\jmeter\rapport\index.html` | 200 utilisateurs : 0 % d'erreur ; 500 utilisateurs : 52 % > 200 ms → DEF-08 |

**SonarQube** tourne dans Docker (conteneur `sonarqube`, port 9000). Le script le démarre tout seul.
À la première connexion dans le navigateur, SonarQube demande de changer le mot de passe `admin` :
ensuite, lancez `.\tests\sonar-analyse.ps1 -Password VotreNouveauMotDePasse`.

**JMeter** est installé dans `..\tools\apache-jmeter-5.6.3`. Pour **voir** le plan de test dans l'interface graphique
(utile devant le professeur) : `..\tools\apache-jmeter-5.6.3\bin\jmeter.bat -t tests\jmeter\EasyVote-charge.jmx`.

---

## 0. Exécuter le plan de test : chaque test, un par un

Liste des identifiants JUnit à tout moment : `.\tests\lancer-tests.ps1 liste`

### A. Techniques STATIQUES (on n'exécute pas le code) — manuel et outillé

| ID | Mode | Comment l'exécuter | Résultat attendu |
|---|---|---|---|
| RV-01 | Manuel (revue) | Ouvrir `easyvote-backend/src/main/resources/application.properties`, **ligne 23** | `86400000` ms = 24 h ≠ 1 h du CDC → DEF-06 |
| RV-02 | Manuel (revue) | Ouvrir `CandidateService.java`, **ligne 71** | rôle CANDIDATE donné au dépôt, pas à la validation → DEF-02 |
| RV-03 | Manuel (revue) | Ouvrir `PhotoUploadService.java`, **ligne 34** | `5_000_000` ≠ 5 Mo (5 242 880) → DEF-01 |
| SA-01 | Outillé | `cd easyvote-frontend; npx tsc -b; cd ..` | aucune erreur |
| SA-02 | Outillé | `cd easyvote-frontend; npx eslint src/components/chatbot/ChatbotWidget.tsx; cd ..` | 5 erreurs, dont 4 `rules-of-hooks` → DEF-07 |
| SA-03 | Outillé | `cd easyvote-frontend; npm audit; cd ..` | 35 vulnérabilités |

### B. Techniques DYNAMIQUES automatisées — JUnit (un test = une commande)

| ID | Technique | Commande | Attendu |
|---|---|---|---|
| PE-01 / PE-02 / PE-03 | Boîte noire — partition | `.\tests\lancer-tests.ps1 PE-01` (puis PE-02, PE-03) | [OK] |
| VL-01 / VL-02 | Boîte noire — limites | `.\tests\lancer-tests.ps1 VL-01` | [OK] |
| VL-03 | Boîte noire — limites | `.\tests\lancer-tests.ps1 VL-03` | **[ECHEC] DEF-01** |
| R1 / R2 / R3 | Boîte noire — table de décision | `.\tests\lancer-tests.ps1 R1` | [OK] |
| ST-20 / ST-21 / ST-23 | Boîte noire — transition d'état | `.\tests\lancer-tests.ps1 ST-23` | [OK] |
| UT-01a / b / c | Boîte blanche — instructions | `.\tests\lancer-tests.ps1 UT-01a` | [OK] |
| B1 / B2 / B3 | Boîte blanche — branches | `.\tests\lancer-tests.ps1 B2` | [OK] |
| DC-01 / 02 / 03 | Boîte blanche — décisions | `.\tests\lancer-tests.ps1 DC-01` | [OK] |
| CC-1 / 2 / 3 | Boîte blanche — chemins V(G) | `.\tests\lancer-tests.ps1 CC-3` | [OK] |
| T1 / T2 / T3 | Boîte blanche — MC/DC | `.\tests\lancer-tests.ps1 T1` | [OK] |
| UT-CB1 / UT-06 | Unitaire fonct. / non fonct. | `.\tests\lancer-tests.ps1 UT-06` | [OK] |
| UT-CB3 | Unitaire fonctionnel | `.\tests\lancer-tests.ps1 UT-CB3` | **[ECHEC] DEF-04** |
| IT-01 / IT-09 | Intégration | `.\tests\lancer-tests.ps1 IT-09` | [OK] |
| IT-04 | Intégration | `.\tests\lancer-tests.ps1 IT-04` | **[ECHEC] DEF-00** |

(Chaque commande prend environ 30 s : Maven recompile avant de lancer le test.)

### C. Techniques DYNAMIQUES automatisées — API (backend démarré)

| ID | Outil | Commande | Attendu |
|---|---|---|---|
| PM-01 | Postman | Postman → requête **PM-01** → **Send** → onglet *Test Results* | 3 ✓ |
| PM-02 | Postman | Postman → requête **PM-02** → **Send** | 3 ✓ |
| ST-01 → ST-05, ST-NF | Script Node | `node tests/system-tests.mjs` | 12 ✅ |

ST-01 à ST-05 forment **un seul scénario enchaîné** (on ne peut pas voter avant d'avoir créé l'élection) : ils s'exécutent ensemble.

### D. Tests MANUELS (dynamiques)

| ID | Comment l'exécuter | Attendu |
|---|---|---|
| SQL-01 | Requête SQL de l'anonymat (section 4) | doit afficher 0 ligne ; affiche qui a voté pour qui → DEF-00 |
| EX-1, EX-2, EX-3 | `node tests/exploratoire.mjs` (enchaînés) | 3 ❌ → DEF-03, DEF-02, DEF-05 |
| UAT-01 | Navigateur, `talel@test.com` : voter | code de 10 caractères affiché |
| UAT-02 | Navigateur, `achref@test.com` : *Ma campagne* → publier une annonce | annonce visible sur le profil |
| UAT-03 | Navigateur, `ahmed@test.com` : créer → valider → ouvrir le vote → clôturer → PDF | PDF complet |
| MT-01, MT-02 | `.\tests\maintenance-sauvegarde.ps1` | 2 [OK] |

Notez chaque résultat (Passed / Failed) dans un **test run Testiny** : c'est l'**exécution du plan de test**.

---

## 1. Les NIVEAUX de test

| Niveau | Test | Ce qu'il vérifie | Commande | Attendu |
|---|---|---|---|---|
| **Unitaire** (une méthode seule) | PE-01 | Le code OTP `123456` est accepté | `.\tests\lancer-tests.ps1 boitenoire` | [OK] |
| | R1 | Un vote valide renvoie un code de 10 caractères | (même commande) | [OK] |
| | UT-CB1 | Le chatbot répond à « Bonjour » | `.\tests\lancer-tests.ps1 unitaire` | [OK] |
| **Intégration** (API + sécurité + base ensemble) | IT-01 | L'inscription crée un compte non vérifié + envoie l'OTP | `.\tests\lancer-tests.ps1 integration` | [OK] |
| | IT-09 | Route admin : 401 sans connexion, 403 pour un étudiant | (même commande) | [OK] |
| | IT-04 | Le vote est anonyme en base | (même commande) | **[ECHEC] → DEF-00** |
| **Système** (toute l'application) | ST-01 | Scénario complet : création → candidature → vote → résultats | `node tests/system-tests.mjs` | ✅ |
| | ST-02 | Le 2e vote est refusé | (même commande) | ✅ |
| | PM-01 | Connexion admin via l'API (Postman) | Postman → *Run collection* | 3 ✓ |
| **Acceptation** (l'utilisateur réel, manuel) | UAT-01 | Un étudiant vote dans le navigateur | à la main, http://localhost:5173 | code affiché |
| | UAT-03 | L'admin crée une élection et télécharge le PDF | à la main | PDF complet |

## 2. Les TYPES de test

| Type | Test | Ce qu'il vérifie | Commande | Attendu |
|---|---|---|---|---|
| **Fonctionnel** (fait-il la bonne chose ?) | R3 | Un étudiant ayant déjà voté est refusé | `.\tests\lancer-tests.ps1 boitenoire` | [OK] |
| | ST-23 | DRAFT → VOTE (saut d'étape) est refusé | (même commande) | [OK] |
| | PM-01 | La connexion renvoie un jeton et le rôle ADMIN | Postman | 3 ✓ |
| **Non fonctionnel** (vitesse, sécurité) | UT-06 | Le chatbot répond en < 50 ms | `.\tests\lancer-tests.ps1 unitaire` | [OK] |
| | ST-NF | `GET /elections` répond en < 200 ms | `node tests/system-tests.mjs` | ✅ |
| | PM-02 | Route admin sans jeton → 401, en < 200 ms | Postman | 3 ✓ |
| **Structurel** (le code est-il parcouru ?) | B1-B3 | Les 3 branches de la génération des jetons | `.\tests\lancer-tests.ps1 boiteblanche` | [OK] |
| | T1-T3 | MC/DC sur `if (A && B)` | (même commande) | [OK] |
| | JaCoCo | Couverture mesurée (vert / rouge) | ouvrir `easyvote-backend\target\site\jacoco\index.html` | 100 % branches sur VoteTokenService |
| **Lié aux changements** | Confirmation | Après correction de DEF-01, VL-03 passe | voir l'encadré ci-dessous | [OK] |
| | Régression | Après la correction, les autres tests restent verts | `.\tests\lancer-tests.ps1` | 33 tests |
| **Maintenance** | MT-01 | Sauvegarde de la base | `.\tests\maintenance-sauvegarde.ps1` | [OK] |
| | MT-02 | Restauration identique de la base | (même commande) | [OK] |

> **Démo « test lié aux changements » (2 minutes, optionnelle)**
> 1. `.\tests\lancer-tests.ps1 ValeursLimitesCandidatureTest` → VL-03 en **[ECHEC]**
> 2. Dans `easyvote-backend\src\main\java\com\easyvote\backend\service\PhotoUploadService.java`,
>    remplacer `5_000_000` par `5 * 1024 * 1024` (la correction).
> 3. Relancer la même commande → VL-03 **[OK]** = **test de confirmation**.
> 4. `.\tests\lancer-tests.ps1` → rien d'autre n'est cassé = **test de régression**.
> 5. Remettre `5_000_000` après la démo (ou garder la correction).

## 3. Les TECHNIQUES de test

| Technique | Test | Ce qu'il vérifie | Commande | Attendu |
|---|---|---|---|---|
| **Statique : revue** (lire le code) | RV-01 | Jeton JWT = 24 h au lieu de 1 h | ouvrir `application.properties`, ligne `easyvote.jwt.expiration` | défaut DEF-06 |
| **Statique : outil** | ESLint | Règles React (hooks) | `cd easyvote-frontend; npx eslint .; cd ..` | 64 erreurs, DEF-07 |
| | npm audit | Failles des bibliothèques | `cd easyvote-frontend; npm audit; cd ..` | 35 failles |
| **Dynamique boîte noire** (depuis le cahier des charges) | PE-01..03 | Partition d'équivalence (OTP) | `.\tests\lancer-tests.ps1 boitenoire` | 3 [OK] |
| | VL-01..03 | Valeurs limites (slogan 200/201, photo 5 Mo) | (même commande) | 2 [OK], 1 [ECHEC] |
| | R1..R3 | Table de décision (vote) | (même commande) | 3 [OK] |
| **Dynamique boîte blanche** (depuis le code) | UT-01a..c | Couverture des instructions (SHA-256) | `.\tests\lancer-tests.ps1 boiteblanche` | 3 [OK] |
| | B1..B3 | Couverture des branches | (même commande) | 3 [OK] |
| | T1..T3 | MC/DC | (même commande) | 3 [OK] |

## 4. MANUEL ou AUTOMATISÉ

| Mode | Test | Commande | Attendu |
|---|---|---|---|
| **Manuel** | SQL anonymat | voir ci-dessous | « qui a voté pour qui » s'affiche → DEF-00 |
| | Exploratoire EX-3 | `node tests/exploratoire.mjs` | l'admin peut voter → DEF-05 |
| | UAT-01 | navigateur | vote + code |
| **Automatisé** | 33 tests JUnit | `.\tests\lancer-tests.ps1` | 30 [OK], 3 [ECHEC] |
| | 12 vérifications système | `node tests/system-tests.mjs` | 12 ✅ |
| | 2 tests Postman | Postman ou `npx newman run tests/postman/EasyVote.postman_collection.json` | 6 ✓ |

Requête SQL de l'anonymat (test manuel le plus important) :
```powershell
C:\xampp\mysql\bin\mysql.exe -uroot easyvote_db -e "SELECT u.email AS electeur, cu.full_name AS a_vote_pour FROM votes v JOIN vote_tokens t ON t.token_hash=v.token_hash JOIN users u ON u.id=t.user_id JOIN candidates c ON c.id=v.candidate_id JOIN users cu ON cu.id=c.user_id;"
```

---

## Postman : importer et lancer les 2 tests

1. Ouvrir **Postman** → bouton **Import** (en haut à gauche).
2. Glisser le fichier `tests\postman\EasyVote.postman_collection.json`.
3. La collection **EasyVote - Tests API** apparaît à gauche avec PM-01 et PM-02.
4. Cliquer sur **PM-01** → **Send** → onglet **Test Results** en bas : 3 tests verts.
   Faire pareil avec **PM-02**.
5. Pour tout lancer d'un coup : clic droit sur la collection → **Run collection** → **Run**.
6. Pour voir le code des tests : ouvrir une requête → onglet **Scripts** (ou **Tests**) → *Post-response*.

---

## Le jour de la présentation

**Avant (à la maison, la veille)** : lancer une fois tout ce qui suit pour vérifier que tout marche.

**Sur place, dans l'ordre :**
1. Démarrer MySQL (XAMPP → Start). S'il ne démarre pas :
   `C:\xampp\mysql\bin\mysqld.exe --defaults-file=C:\xampp\mysql\bin\my.ini --standalone` (terminal dédié).
2. `docker stop web` (libère le port 8082).
3. Terminal 1 — backend :
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-21.0.11"; $env:Path = "$env:JAVA_HOME\bin;$env:Path"
   $mvn = "$env:USERPROFILE\.m2\wrapper\dists\apache-maven-3.8.6-bin\1ks0nkde5v1pk9vtc31i9d0lcd\apache-maven-3.8.6\bin\mvn.cmd"
   cd easyvote-backend; & $mvn spring-boot:run
   ```
   attendre `Started BackendApplication`.
4. Terminal 2 — frontend : `cd easyvote-frontend; npm run dev`.
5. Terminal 3 — la démo des tests, dans cet ordre (≈ 10 min) :

| # | Montrer | Commande | Phrase à dire |
|---|---|---|---|
| 1 | Le site marche | navigateur, `ahmed@test.com` / `password123` | « Voici l'application testée. » |
| 2 | Boîte noire | `.\tests\lancer-tests.ps1 boitenoire` | « Les valeurs limites ont trouvé un défaut sur la photo de 5 Mo. » |
| 3 | Boîte blanche + couverture | `.\tests\lancer-tests.ps1 boiteblanche` puis ouvrir JaCoCo | « On mesure le code réellement exécuté. » |
| 4 | Intégration | `.\tests\lancer-tests.ps1 integration` | « L'anonymat échoue. » |
| 5 | Preuve SQL | requête SQL ci-dessus | « On voit qui a voté pour qui : défaut critique. » |
| 6 | Système | `node tests/system-tests.mjs` | « Le scénario complet passe : 12 sur 12. » |
| 7 | Postman | Run collection | « Tests d'API fonctionnels et de sécurité. » |
| 8 | Exploratoire | `node tests/exploratoire.mjs` | « L'administrateur peut voter, c'est interdit. » |
| 9 | Maintenance | `.\tests\maintenance-sauvegarde.ps1` | « Sauvegarde et restauration vérifiées. » |
| 10 | Statique | `cd easyvote-frontend; npx eslint .` | « L'analyse statique trouve un défaut latent. » |

**Si une commande `.ps1` est bloquée** (« l'exécution de scripts est désactivée ») :
`Set-ExecutionPolicy -Scope Process Bypass` puis relancer.
