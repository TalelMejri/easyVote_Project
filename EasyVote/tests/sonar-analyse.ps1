# ============================================================
# EasyVote - Analyse statique avec SonarQube (+ couverture JaCoCo des tests JUnit)
# Prerequis : Docker. Le conteneur SonarQube s'appelle "sonarqube" (port 9000).
# Usage : .\tests\sonar-analyse.ps1                          (compte admin / admin)
#         .\tests\sonar-analyse.ps1 -Password MonMotDePasse  (si vous l'avez change)
# Resultat : http://localhost:9000/dashboard?id=easyvote
# ============================================================
param([string]$User = "admin", [string]$Password = "admin")

$sonar = "http://localhost:9000"

# 1. Demarrer SonarQube (cree le conteneur la premiere fois)
docker start sonarqube *> $null
if ($LASTEXITCODE -ne 0) {
    docker run -d --name sonarqube -p 9000:9000 -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true sonarqube:10.6-community | Out-Null
}
Write-Host "Attente du demarrage de SonarQube..."
do { Start-Sleep 3; try { $st = (Invoke-RestMethod "$sonar/api/system/status").status } catch { $st = "" } } until ($st -eq "UP")

# 2. Jeton d'analyse (genere a chaque lancement)
$auth = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${User}:${Password}")) }
try { Invoke-RestMethod -Method Post -Headers $auth "$sonar/api/projects/create?project=easyvote&name=EasyVote" | Out-Null } catch {}
$token = (Invoke-RestMethod -Method Post -Headers $auth "$sonar/api/user_tokens/generate?name=analyse-$(Get-Date -Format yyyyMMddHHmmss)&type=GLOBAL_ANALYSIS_TOKEN").token

# 3. Build + tests JUnit + JaCoCo + analyse
$jdk = Get-ChildItem "C:\Program Files\Java" -Directory -Filter "jdk-21*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($jdk) { $env:JAVA_HOME = $jdk.FullName; $env:Path = "$($jdk.FullName)\bin;$env:Path" }
$mvn = (Get-Command mvn -ErrorAction SilentlyContinue).Source
if (-not $mvn) { $mvn = Get-ChildItem "$env:USERPROFILE\.m2\wrapper\dists" -Recurse -Filter "mvn.cmd" | Select-Object -First 1 -ExpandProperty FullName }

Push-Location (Join-Path $PSScriptRoot "..\easyvote-backend")
Write-Host "Analyse en cours (environ 1 a 2 minutes)..."
& $mvn -q clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar "-Dsonar.host.url=$sonar" "-Dsonar.token=$token" "-Dsonar.projectKey=easyvote" "-Dsonar.projectName=EasyVote" *> $null
Pop-Location
Start-Sleep 8

# 4. Resume
$m = (Invoke-RestMethod -Headers $auth "$sonar/api/measures/component?component=easyvote&metricKeys=ncloc,bugs,vulnerabilities,security_hotspots,code_smells,coverage,duplicated_lines_density,complexity").component.measures
$gate = (Invoke-RestMethod -Headers $auth "$sonar/api/qualitygates/project_status?projectKey=easyvote").projectStatus.status
Write-Host "`nQuality Gate : $gate"
$m | Sort-Object metric | ForEach-Object { Write-Host ("  {0,-26} {1}" -f $_.metric, $_.value) }
Write-Host "`nTableau de bord : $sonar/dashboard?id=easyvote"
