[CmdletBinding()]
param(
    [string] $EvidenceManifest,
    [string] $ExpectedVersion,
    [switch] $Build,
    [string] $CoordinatedManifest,
    [switch] $SetupCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Maintenance.Common.ps1')
$root = Split-Path $PSScriptRoot -Parent
$catalog = Get-MaintenanceCatalog -RepositoryRoot $root
$coordinatedVersions = @{}
if ($CoordinatedManifest) {
    $coordinated = Get-Content -LiteralPath $CoordinatedManifest -Raw | ConvertFrom-Json
    if ($coordinated.schemaVersion -ne 1 -or $coordinated.sourceProvenance -cne 'nuget-commit' -or $coordinated.destination -cne 'hossnrabbit/active-directory-aspnetcore-webapp-openidconnect-v2') { throw 'Invalid coordinated source manifest destination/provenance.' }
    $updates = @($coordinated.packages | Where-Object selected)
    if (@($updates.package | Sort-Object -Unique).Count -ne $catalog.packages.Count -or $updates.Count -ne $catalog.packages.Count -or (Compare-Object @($updates.package | Sort-Object) @($catalog.packages | Sort-Object))) { throw 'Coordinated evidence must cover exactly the existing direct IdWeb packages.' }
    foreach ($entry in $coordinated.packages) {
        if ((Get-FileHash -LiteralPath $entry.indexPath -Algorithm SHA256).Hash -cne $entry.indexSha256) { throw 'Original latest-version index changed.' }
        $index = Get-Content -LiteralPath $entry.indexPath -Raw | ConvertFrom-Json
        $latest = @($index.versions | Where-Object { $_ -match '^\d+\.\d+\.\d+$' } | Sort-Object { [version]$_ } -Descending)[0]
        if ($entry.targetVersion -cne $latest) { throw 'Target is not the recorded latest stable NuGet version.' }
        if (!$entry.selected) {
            if ($entry.package -cne 'Microsoft.Identity.Client' -or $entry.manifestPath) { throw 'Unexpected unselected dependency evidence.' }
            continue
        }
        if ((Get-FileHash -LiteralPath $entry.manifestPath -Algorithm SHA256).Hash -cne $entry.manifestSha256) { throw 'Original coordinated package manifest changed.' }
        $packageEvidence = Get-Content -LiteralPath $entry.manifestPath -Raw | ConvertFrom-Json
        if ($packageEvidence.package -cne $entry.package -or $packageEvidence.targetVersion -cne $entry.targetVersion) { throw 'Coordinated package identity/version mismatch.' }
        $coordinatedVersions[$entry.package] = $entry.targetVersion
    }
    if (!$EvidenceManifest) {
        foreach ($entry in $updates) {
            & $PSCommandPath -EvidenceManifest $entry.manifestPath -ExpectedVersion $entry.targetVersion -CoordinatedManifest $CoordinatedManifest -SetupCheck:$SetupCheck
        }
    }
}
if ($SetupCheck -and !$EvidenceManifest -and !$CoordinatedManifest) { throw 'SetupCheck requires original evidence.' }
if ($ExpectedVersion -and !$EvidenceManifest) { throw 'Exact-version maintenance validation requires the original evidence manifest.' }
if ($EvidenceManifest) {
    $manifest = Get-Content -LiteralPath $EvidenceManifest -Raw | ConvertFrom-Json
    if ($manifest.schemaVersion -ne 1 -or $manifest.sourceProvenance -cne 'nuget-commit' -or $manifest.repository -cne 'https://github.com/AzureAD/microsoft-identity-web.git') { throw 'Invalid IdWeb source manifest.' }
    if (!$ExpectedVersion -or $manifest.targetVersion -cne $ExpectedVersion) { throw 'Expected version must match original setup evidence.' }
    $selected = @(Get-MaintenanceSelection -Package $manifest.package -TargetVersion $ExpectedVersion)
    if (Compare-Object @($selected.project | Sort-Object) @($manifest.samples.project | Sort-Object)) { throw 'Manifest project scope does not match the catalog selection.' }
    $versions = @(@($ExpectedVersion) + @($manifest.samples | Where-Object status -NE 'newer' | ForEach-Object originalVersion) | Select-Object -Unique)
    if (Compare-Object @($versions | Sort-Object) @($manifest.releases.version | Sort-Object)) { throw 'Missing or duplicate verified source releases.' }
    foreach ($release in $manifest.releases) {
        if ((Get-FileHash -LiteralPath $release.packagePath -Algorithm SHA256).Hash -cne $release.packageSha256) { throw 'Original package evidence changed.' }
        $commit = & git -C $release.sourcePath rev-parse HEAD
        if ($LASTEXITCODE -ne 0 -or $commit -cne $release.commit) { throw 'Source checkout commit changed.' }
        $dirty = @(& git -C $release.sourcePath status --porcelain --untracked-files=normal)
        if ($LASTEXITCODE -ne 0 -or $dirty.Count) { throw 'Original source evidence is not immutable.' }
    }
    foreach ($sample in $manifest.samples) {
        if ($sample.originalVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid original version.' }
        $status = if ([version]$sample.originalVersion -gt [version]$ExpectedVersion) { 'newer' } elseif ($sample.originalVersion -ceq $ExpectedVersion) { 'current' } else { 'update' }
        if ($sample.status -cne $status) { throw 'Invalid sample update disposition.' }
        [xml] $project = Get-Content -LiteralPath (Join-Path $root $sample.project) -Raw
        $frameworks = @($project.SelectNodes('//TargetFramework | //TargetFrameworks') | ForEach-Object InnerText)
        if (Compare-Object @($sample.frameworks) $frameworks) { throw 'Target frameworks changed.' }
        $actualReferences = @($project.SelectNodes('//PackageReference') | ForEach-Object { [ordered]@{ package = $_.Include; version = $_.Version } } | Sort-Object { $_.package })
        $expectedReferences = @($sample.references | ForEach-Object {
            $version = if (!$SetupCheck -and $coordinatedVersions.ContainsKey($_.package) -and [version]$_.version -lt [version]$coordinatedVersions[$_.package]) {
                $coordinatedVersions[$_.package]
            } elseif (!$SetupCheck -and !$CoordinatedManifest -and $_.package -ceq $manifest.package -and $status -ne 'newer') {
                $ExpectedVersion
            } else { $_.version }
            [ordered]@{ package = $_.package; version = $version }
        } | Sort-Object { $_.package })
        if (($actualReferences | ConvertTo-Json -Compress) -cne ($expectedReferences | ConvertTo-Json -Compress)) { throw 'Package changes are outside the verified update scope or attempt a downgrade.' }
        if ($status -ne 'newer') {
            $comparisons = @($manifest.comparisons | Where-Object { $_.baselineVersion -ceq $sample.originalVersion -and $_.targetVersion -ceq $ExpectedVersion })
            if ($comparisons.Count -ne 1 -or (Get-FileHash -LiteralPath $comparisons[0].path -Algorithm SHA256).Hash -cne $comparisons[0].sha256) { throw 'Prepared baseline-to-target source comparison changed or is missing.' }
        }
    }
}
if ($SetupCheck -and $Build) { throw 'SetupCheck cannot stand in for a required candidate build.' }
if ($Build) {
    foreach ($path in $catalog.projects) {
        & dotnet build (Join-Path $root $path) --configuration Release --verbosity minimal
        if ($LASTEXITCODE -ne 0) { throw "Build failed: $path" }
    }
} else { Write-Host 'Builds: NOT RUN. Use -Build only on an approved build host.' }
Write-Host 'PASS: retained IdWeb catalog and requested evidence checks. Live sign-in/downstream calls: NOT RUN.'