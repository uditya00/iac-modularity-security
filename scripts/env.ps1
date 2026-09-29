# Usage (from the project root, in PowerShell):   . .\scripts\env.ps1
# Creates a random DB password once (.env is git-ignored) and sets the variables.
if (-not (Test-Path .env)) {
  $b = New-Object byte[] 16
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
  $pw = ($b | ForEach-Object { $_.ToString("x2") }) -join ""
  "TFSTATE_DB_PASSWORD=$pw" | Set-Content -Encoding ascii .env
}
Get-Content .env | ForEach-Object {
  $k, $v = $_ -split "=", 2
  Set-Item -Path "env:$k" -Value $v
}
$env:PG_CONN_STR = "postgres://tfstate:$($env:TFSTATE_DB_PASSWORD)@127.0.0.1:5432/tfstate?sslmode=disable"
# On Windows the Docker provider must use the named pipe instead of a Linux socket
$env:DOCKER_HOST = "npipe:////.//pipe//docker_engine"
Write-Host "Environment ready (password is in .env, not in Git)."
