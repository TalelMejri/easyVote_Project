# ============================================================
# EasyVote - Lance les tests automatises du backend (JUnit + JaCoCo)
#
# Usage (PowerShell, depuis la racine du projet) :
#   .\tests\lancer-tests.ps1                 -> tous les tests (38)
#   .\tests\lancer-tests.ps1 boitenoire      -> techniques boite noire (12)
#   .\tests\lancer-tests.ps1 boiteblanche    -> techniques boite blanche (15)
#   .\tests\lancer-tests.ps1 unitaire        -> chatbot + regression (3)
#   .\tests\lancer-tests.ps1 integration     -> API + securite + BDD H2 + temps de reponse (4)
#   .\tests\lancer-tests.ps1 McdcPeriodeVoteTest   -> une seule classe
#   .\tests\lancer-tests.ps1 PE-01           -> UN SEUL test, par son identifiant
#   .\tests\lancer-tests.ps1 acceptation     -> recette UAT (4)
#   .\tests\lancer-tests.ps1 liste           -> affiche tous les identifiants
# ============================================================
param([string]$Famille = "tous")

# Identifiant du plan de test -> Classe#methode JUnit
$tests = [ordered]@{
    # Boite noire
    "PE-01"  = @("PartitionEquivalenceOtpTest#codeValideSixChiffres",      "BN partition : OTP 123456 accepte")
    "PE-02"  = @("PartitionEquivalenceOtpTest#codeTropCourt",              "BN partition : OTP 12345 rejete")
    "PE-03"  = @("PartitionEquivalenceOtpTest#codeNonNumerique",           "BN partition : OTP 12AB56 rejete")
    "VL-01"  = @("ValeursLimitesCandidatureTest#sloganExactementALaLimite", "BN limites : slogan 200 car. accepte")
    "VL-02"  = @("ValeursLimitesCandidatureTest#sloganJusteAuDessusDeLaLimite", "BN limites : slogan 201 car. rejete")
    "VL-03"  = @("ValeursLimitesCandidatureTest#photoExactementCinqMo",    "BN limites : photo 5 Mo acceptee (ECHEC attendu, DEF-01)")
    "R1"     = @("TableDecisionVoteTest#r1VoteAutorise",                   "BN table de decision : vote valide")
    "R2"     = @("TableDecisionVoteTest#r2ElectionNonActive",              "BN table de decision : election fermee")
    "R3"     = @("TableDecisionVoteTest#r3DejaVote",                       "BN table de decision : deja vote")
    "ST-20"  = @("TransitionEtatElectionTest#draftVersCampagne",           "BN transition : DRAFT -> CAMPAIGN")
    "ST-21"  = @("TransitionEtatElectionTest#campagneVersVote",            "BN transition : CAMPAIGN -> VOTE")
    "ST-23"  = @("TransitionEtatElectionTest#sautDEtatInterdit",           "BN transition : DRAFT -> VOTE refuse")
    # Boite blanche
    "UT-01a" = @("CouvertureInstructionsHashTest#vecteurNist",             "BB instructions : SHA-256 vecteur NIST")
    "UT-01b" = @("CouvertureInstructionsHashTest#formatEtDeterminisme",    "BB instructions : hash 64 hex")
    "UT-01c" = @("CouvertureInstructionsHashTest#jetonsBrutsUniques",      "BB instructions : jetons uniques")
    "B1"     = @("CouvertureBranchesTokensTest#brancheElectionIntrouvable", "BB branches : election introuvable")
    "B2"     = @("CouvertureBranchesTokensTest#brancheIdempotence",        "BB branches : idempotence")
    "B3"     = @("CouvertureBranchesTokensTest#brancheGeneration",         "BB branches : generation des jetons")
    "DC-01"  = @("CouvertureDecisionsConditionsTest#datesValides",         "BB decisions : dates valides")
    "DC-02"  = @("CouvertureDecisionsConditionsTest#campagneDeDureeNulle", "BB decisions : campagne nulle")
    "DC-03"  = @("CouvertureDecisionsConditionsTest#voteInverse",          "BB decisions : vote inverse")
    "CC-1"   = @("ComplexiteCyclomatiqueVoteTest#cheminCompteNonVerifie",  "BB chemins : compte non verifie")
    "CC-2"   = @("ComplexiteCyclomatiqueVoteTest#cheminCandidatAutreElection", "BB chemins : candidat autre election")
    "CC-3"   = @("ComplexiteCyclomatiqueVoteTest#cheminJetonGenereALaVolee", "BB chemins : jeton a la volee")
    "T1"     = @("McdcPeriodeVoteTest#t1FinDepassee",                      "BB MC/DC : A=V B=V")
    "T2"     = @("McdcPeriodeVoteTest#t2FinFuture",                        "BB MC/DC : A=V B=F")
    "T3"     = @("McdcPeriodeVoteTest#t3SansDateDeFin",                    "BB MC/DC : A=F")
    # Unitaire chatbot
    "UT-01"  = @("ChatbotRulesTest#salutation",                            "Unitaire fonctionnel : Bonjour")
    "UT-06"  = @("ChatbotRulesTest#performanceMoinsDe50ms",                "Unitaire non fonctionnel : < 50 ms")
    "UT-M01" = @("RegressionResultatsTest#calculDesResultatsInchange",     "Unitaire regression : calcul des resultats inchange")
    # Integration
    "IT-01"  = @("ApiIntegrationTest#inscription",                         "Integration : inscription + OTP")
    "IT-09"  = @("ApiIntegrationTest#securiteRbac",                        "Integration : 401 / 403")
    "IT-04"  = @("ApiIntegrationTest#voteAnonymeEnBase",                   "Integration : anonymat (ECHEC attendu, DEF-00)")
    "IT-07"  = @("ApiIntegrationTest#tempsDeReponseListeElections",        "Integration non fonctionnel : GET /elections <= 200 ms")
    # Acceptation
    "UAT-01" = @("AcceptationTest#parcoursEtudiant",                       "Acceptation fonctionnel : connexion -> consultation -> vote")
    "UAT-06" = @("AcceptationTest#pdfOfficielExploitable",                 "Acceptation non fonctionnel : PDF officiel exploitable")
    "UAT-07" = @("AcceptationTest#rolesEtDroitsConformes",                 "Acceptation structurel : test croise des 3 roles")
    "UAT-M03" = @("AcceptationTest#droitsInchangesApresMiseAJour",         "Acceptation regression : droits inchanges")
}

if ($Famille -eq "liste") {
    foreach ($id in $tests.Keys) { Write-Host ("  {0,-7} {1}" -f $id, $tests[$id][1]) }
    Write-Host "`nExemple : .\tests\lancer-tests.ps1 PE-01"
    exit 0
}

# 1. Java 21 (le projet ne compile pas avec Java 25 : Lombok trop ancien)
$jdk = Get-ChildItem "C:\Program Files\Java" -Directory -Filter "jdk-21*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($jdk) { $env:JAVA_HOME = $jdk.FullName; $env:Path = "$($jdk.FullName)\bin;$env:Path" }

# 2. Maven : mvn du PATH, sinon celui mis en cache par le wrapper, sinon mvnw.cmd
$mvn = (Get-Command mvn -ErrorAction SilentlyContinue).Source
if (-not $mvn) {
    $mvn = Get-ChildItem "$env:USERPROFILE\.m2\wrapper\dists" -Recurse -Filter "mvn.cmd" -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $mvn) { $mvn = Join-Path $PSScriptRoot "..\easyvote-backend\mvnw.cmd" }

# 3. Selection des tests
$filtre = switch ($Famille) {
    "tous"         { $null }
    "boitenoire"   { "**/boitenoire/*Test" }
    "boiteblanche" { "**/boiteblanche/*Test" }
    "unitaire"     { "**/unitaire/*Test" }
    "integration"  { "**/integration/*Test" }
    "acceptation"  { "**/acceptation/*Test" }
    default        { if ($tests.Contains($Famille)) { $tests[$Famille][0] } else { $Famille } }
}
$mvnArgs = @("-q", "clean", "test")
if ($filtre) { $mvnArgs += "-Dtest=$filtre" }

Write-Host "Java : $env:JAVA_HOME"
Write-Host "Tests : $Famille   (patientez, environ 30 s a 1 min)`n"

# 4. clean obligatoire : l'extension Java de VS Code ecrit des classes sans Lombok dans target/
$backend = Join-Path $PSScriptRoot "..\easyvote-backend"
Push-Location $backend
& $mvn @mvnArgs *> $null
Pop-Location

# 5. Affichage lisible : chaque classe, chaque test (phrase @DisplayName), OK ou ECHEC
$reports = Get-ChildItem (Join-Path $backend "target\surefire-reports") -Filter "TEST-*.xml" -ErrorAction SilentlyContinue
if (-not $reports) { Write-Host "Aucun rapport : la compilation a echoue. Relancez avec : & `"$mvn`" test" -ForegroundColor Red; exit 1 }

$total = 0; $echecs = 0
foreach ($r in $reports | Sort-Object Name) {
    [xml]$x = Get-Content $r.FullName -Encoding UTF8
    $suite = $x.testsuite
    Write-Host "`n$($suite.name)" -ForegroundColor Cyan
    foreach ($tc in $suite.testcase | Sort-Object name) {
        $total++
        $probleme = $tc.failure, $tc.error | Where-Object { $_ } | Select-Object -First 1
        if ($probleme) {
            $echecs++
            Write-Host "   [ECHEC] $($tc.name)" -ForegroundColor Red
            $msg = ($probleme.message -replace "\s+", " ").Trim()
            if ($msg.Length -gt 160) { $msg = $msg.Substring(0, 160) + "..." }
            Write-Host "           -> $msg" -ForegroundColor DarkYellow
        } else {
            Write-Host "   [OK]    $($tc.name)" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== Bilan : $total tests, $($total - $echecs) reussis, $echecs en echec ===" -ForegroundColor White
if ($echecs -gt 0) { Write-Host "Un ECHEC = le code ne respecte pas le cahier des charges = defaut trouve (voir tests\GUIDE_TESTS.md section 7)." -ForegroundColor DarkYellow }
Write-Host "Couverture (boite blanche) : easyvote-backend\target\site\jacoco\index.html"
