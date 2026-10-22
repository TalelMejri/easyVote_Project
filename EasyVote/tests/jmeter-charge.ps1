# ============================================================
# EasyVote - Test de CHARGE avec JMeter (backend demarre sur 8082)
# Usage : .\tests\jmeter-charge.ps1                 -> 50 utilisateurs, 10 boucles
#         .\tests\jmeter-charge.ps1 -Users 100      -> 100 utilisateurs simultanes
# Resultat : tableau dans le terminal + rapport HTML tests\jmeter\rapport\index.html
# ============================================================
param([int]$Users = 50, [int]$Loops = 10, [int]$Rampup = 10)

$jdk = Get-ChildItem "C:\Program Files\Java" -Directory -Filter "jdk-21*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($jdk) { $env:JAVA_HOME = $jdk.FullName; $env:Path = "$($jdk.FullName)\bin;$env:Path" }

$jmeter  = Join-Path $PSScriptRoot "..\..\tools\apache-jmeter-5.6.3\bin\jmeter.bat"
$plan    = Join-Path $PSScriptRoot "jmeter\EasyVote-charge.jmx"
$jtl     = Join-Path $PSScriptRoot "jmeter\resultats.jtl"
$rapport = Join-Path $PSScriptRoot "jmeter\rapport"
if (-not (Test-Path $jmeter)) { Write-Host "JMeter introuvable : $jmeter" -ForegroundColor Red; exit 1 }

Write-Host "JMeter : $Users utilisateurs simultanes, $Loops boucles, montee en charge $Rampup s ..."
& $jmeter -n -f -t $plan -l $jtl -e -o $rapport "-Jusers=$Users" "-Jloops=$Loops" "-Jrampup=$Rampup" *> $null

$stats = Get-Content (Join-Path $rapport "statistics.json") -Raw | ConvertFrom-Json
Write-Host ""
Write-Host ("{0,-42} {1,8} {2,9} {3,10} {4,10} {5,10}" -f "Requete", "Appels", "Erreurs", "Moyenne", "90e pct", "Debit/s")
foreach ($p in $stats.PSObject.Properties) {
    $s = $p.Value
    $couleur = if ($s.errorPct -eq 0) { "Green" } else { "Yellow" }
    Write-Host ("{0,-42} {1,8} {2,8:N1}% {3,8:N0}ms {4,8:N0}ms {5,10:N1}" -f $s.transaction, $s.sampleCount, $s.errorPct, $s.meanResTime, $s.pct1ResTime, $s.throughput) -ForegroundColor $couleur
}
Write-Host "`n'Erreurs' = reponse non 200 OU reponse plus lente que 200 ms (assertion du CDC 5.1)."
Write-Host "Rapport HTML : $rapport\index.html"
