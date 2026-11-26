$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Maintenance.Common.ps1')
$references = @(Get-MaintenanceSelection -Package 'Microsoft.Identity.Web.UI' -TargetVersion '0.0.1')
$highestVersion = [version] ($references.originalVersion | Sort-Object { [version] $_ } -Descending | Select-Object -First 1)
$nextMajor = $highestVersion.Major + 1
$targetVersion = "$nextMajor.10.0"
$state = @{ versions = @("$nextMajor.8.2", $targetVersion, "$($nextMajor + 1).0.0-preview.1"); calls = 0 }
function Invoke-RestMethod {
    param($Uri, $TimeoutSec, $MaximumRedirection)
    if ($Uri -cne 'https://api.nuget.org/v3-flatcontainer/microsoft.identity.web.ui/index.json' -or
        $TimeoutSec -ne 30 -or $MaximumRedirection -ne 0) { throw 'Unexpected network request.' }
    $state.calls++
    @{ versions = $state.versions }
}
function Assert-Release {
    param([bool] $Condition, [string] $Message)
    if (!$Condition) { throw $Message }
}
function Assert-ReleaseFailure {
    param([scriptblock] $Action)
    $failed = $false
    try { & $Action | Out-Null } catch { $failed = $true }
    Assert-Release $failed 'Expected discovery to fail closed.'
}
$result = & (Join-Path $PSScriptRoot 'Find-MaintenanceRelease.ps1')
Assert-Release ($result.version -ceq $targetVersion) 'Stable versions must sort numerically and exclude prereleases.'
Assert-Release ($result.updateAvailable -and $result.projects.Count -eq $references.Count) 'Outdated retained projects were not selected.'
Assert-Release ($result.releaseUrl -ceq "https://github.com/AzureAD/microsoft-identity-web/releases/tag/$targetVersion") 'Unexpected release URL.'
Assert-Release (@($result.projects | Where-Object { $_ -match 'B2C|Sovereign|UiTests' }).Count -eq 0) 'Excluded/support projects selected.'
$state.versions = @('0.0.1')
$result = & (Join-Path $PSScriptRoot 'Find-MaintenanceRelease.ps1')
Assert-Release (!$result.updateAvailable -and $result.projects.Count -eq 0) 'Discovery must never downgrade projects.'
$state.versions = @('99.0.0-preview', 'invalid')
Assert-ReleaseFailure { & (Join-Path $PSScriptRoot 'Find-MaintenanceRelease.ps1') }
$previousCalls = $state.calls
Assert-ReleaseFailure { & (Join-Path $PSScriptRoot 'Find-MaintenanceRelease.ps1') -Package 'Microsoft.Identity.Client' }
Assert-Release ($state.calls -eq $previousCalls) 'Unapproved packages must fail before network access.'
$state.versions = @($targetVersion)
function Invoke-RestMethod { throw 'Simulated feed failure' }
Assert-ReleaseFailure { & (Join-Path $PSScriptRoot 'Find-MaintenanceRelease.ps1') }
'PASS: offline release discovery checks (mocked feed only).'