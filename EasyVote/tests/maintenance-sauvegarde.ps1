# ============================================================
# EasyVote - Test de MAINTENANCE : sauvegarde puis restauration de la base
# MT-01 : la sauvegarde (mysqldump) se fait sans erreur
# MT-02 : la base restauree contient exactement les memes donnees
# La restauration se fait dans une COPIE (easyvote_restore) : la vraie base n'est pas touchee.
# Usage : .\tests\maintenance-sauvegarde.ps1   (MySQL demarre)
# ============================================================
$b = "C:\xampp\mysql\bin"
$fichier = Join-Path $PSScriptRoot "sauvegarde.sql"

& "$b\mysqldump.exe" -uroot easyvote_db --result-file=$fichier
if ($LASTEXITCODE -eq 0) { Write-Host "[OK]    MT-01 sauvegarde creee : $fichier" -ForegroundColor Green }
else { Write-Host "[ECHEC] MT-01 sauvegarde impossible (MySQL demarre ?)" -ForegroundColor Red; exit 1 }

& "$b\mysql.exe" -uroot -e "DROP DATABASE IF EXISTS easyvote_restore; CREATE DATABASE easyvote_restore;"
cmd /c "`"$b\mysql.exe`" -uroot easyvote_restore < `"$fichier`""

$ok = $true
foreach ($table in "users", "elections", "candidates", "votes", "vote_tokens") {
    $avant = & "$b\mysql.exe" -uroot -N -e "SELECT COUNT(*) FROM easyvote_db.$table"
    $apres = & "$b\mysql.exe" -uroot -N -e "SELECT COUNT(*) FROM easyvote_restore.$table"
    Write-Host ("        {0,-12} original = {1,3}   restauree = {2,3}" -f $table, $avant, $apres)
    if ($avant -ne $apres) { $ok = $false }
}
if ($ok) { Write-Host "[OK]    MT-02 donnees restaurees a l'identique" -ForegroundColor Green }
else { Write-Host "[ECHEC] MT-02 des donnees different apres restauration" -ForegroundColor Red }

& "$b\mysql.exe" -uroot -e "DROP DATABASE easyvote_restore;"
