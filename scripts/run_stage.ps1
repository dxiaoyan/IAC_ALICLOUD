param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('dev','qa','prd')]
  [string]$Env,

  [Parameter(Mandatory = $true)]
  [ValidateSet('plan','apply','destroy')]
  [string]$Action
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$base = Join-Path $root "live/$Env/cn-shanghai"

$requiredEnvVars = @(
  'ALICLOUD_TABLESTORE_ENDPOINT',
  'ALICLOUD_TABLESTORE_INSTANCE'
)

$missingEnvVars = @($requiredEnvVars | Where-Object { [string]::IsNullOrWhiteSpace((Get-Item -Path "Env:$_" -ErrorAction SilentlyContinue).Value) })
if ($missingEnvVars.Count -gt 0) {
  throw "Missing required environment variables: $($missingEnvVars -join ', ')."
}

$stages = @(
  @('kms','ram','sls','vpc_inputs'),
  @('sg','nacl','acr','eventbridge','mns'),
  @('oss','nas','backup','rds_pg','redis'),
  @('alb','cdn','ecs','acs','fc','dataworks')
)

foreach ($stage in $stages) {
  Write-Host "=== Stage: $($stage -join ', ') ==="
  foreach ($comp in $stage) {
    $path = Join-Path $base $comp
    Push-Location $path
    try {
      terragrunt init -upgrade
      terragrunt $Action
    }
    finally {
      Pop-Location
    }
  }
}
