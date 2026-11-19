param(
    [string] $Package = 'Microsoft.Identity.Web.UI',
    [string] $RepositoryRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Maintenance.Common.ps1')
$catalog = Get-MaintenanceCatalog -RepositoryRoot $RepositoryRoot
if ($Package -cne 'Microsoft.Identity.Web.UI' -or $Package -cnotin $catalog.packages) {
    throw 'Scheduled discovery is limited to Microsoft.Identity.Web.UI in this test.'
}
$uri = "https://api.nuget.org/v3-flatcontainer/$($Package.ToLowerInvariant())/index.json"
$index = Invoke-RestMethod -Uri $uri -TimeoutSec 30 -MaximumRedirection 0
$stable = @($index.versions | Where-Object { $_ -is [string] -and $_ -cmatch '^\d+\.\d+\.\d+$' } |
    Sort-Object { [version] $_ } -Descending)
if (!$stable.Count) { throw 'NuGet returned no supported stable package versions.' }
$target = $stable[0]
$selection = @(Get-MaintenanceSelection -Package $Package -TargetVersion $target -RepositoryRoot $RepositoryRoot)
$updates = @($selection | Where-Object { $_.status -eq 'update' })
[pscustomobject]@{
    package = $Package
    version = $target
    releaseUrl = "https://github.com/AzureAD/microsoft-identity-web/releases/tag/$target"
    updateAvailable = ($updates.Count -gt 0)
    projects = @($updates | ForEach-Object { $_.project })
}