# IdWeb Sample Maintenance Harness

## Approved Latest Upgrade

The only authorized destination is
hossnrabbit/active-directory-aspnetcore-webapp-openidconnect-v2. Reuse the existing
harness on test/idweb-harness-e2e; do not redirect work to console/docs-code samples.
The maintainer approved a PR updating all existing direct IdWeb packages together
to their latest stable official NuGet versions. All thirteen retained apps currently
use IdWeb 3.7.0. No retained project directly references Microsoft.Identity.Client;
MSAL's latest version is recorded separately, not injected as a new dependency.

Trusted hosted setup uses Get-IdWebSourceEvidence.ps1 -CoordinatedLatest and
Validate-Maintenance.ps1 -CoordinatedManifest <original-manifest> -SetupCheck.
It records hash-bound official version indexes and per-package original manifests,
downloads exact official NuGet archives, and fetches their full recorded IdWeb
source commits. A disposable coordinated package build restores original project
bytes before the implementer starts. No SDK build scripts/tests or live app flows run.

The implementer must obtain an actual source-backed planner READY, apply the
scoped updates, build against ORIGINAL coordinated evidence, and obtain independent
review on the actual candidate. Standalone setup success does not prove agent import,
review, or a completed upgrade. Missing gates remain BLOCKED/PARTIAL.
No schedule, automatic assignment, default branch or upstream changes are enabled.

## Historical Single-Package Discovery

The older issue-creation job remains disabled. The commands below describe its
historical single-package dry runs, not the coordinated latest upgrade path.

Run release-maintenance.yml against test/idweb-harness-e2e with
detect_latest=true and dry_run=true. Leave package, version, release_notes_url
and event_key empty, and assign_copilot=false. The hosted runner queries only
the public NuGet version index for Microsoft.Identity.Web.UI, selects the highest
three-part stable version numerically, and compares direct references in retained
catalog projects. It does not download packages/source, build samples, edit sample
code or access credentials. Feed errors fail the run rather than imply no updates.
The summary reports the version and number of outdated retained projects.

Repeat with dry_run=false to create or reuse an Actions-bot maintenance issue
only when an outdated retained reference exists. Open and closed issues share
the existing repository/package/version deduplication marker, including issues
created through manual release dispatch. All issue-creation runs are serialized.
Support/excluded projects are not selected, prereleases are ignored, and newer
references are never downgraded. No update means no issue. Scheduled discovery
does not need the ADO coordinator, its service connection, or a custom token.

The weekday schedule is 07:23 UTC, but it is INACTIVE on this non-default branch.
The fork/test-ref/actor guard also intentionally prevents execution on master or
upstream. Activating a real schedule requires separate approval for default-branch
installation and guard changes. Keep workflow_dispatch for manual testing;
GitHub schedules can be delayed, and public-repository schedules disable after
60 days of inactivity. Do not change the default branch to bypass this boundary.

Discovery rejects assign_copilot=true and conflicting manual release inputs.
dry_run suppresses assignment even for a manually supplied approved release.
Detected issues are proposals, not source-update approval: the candidate release
URL has not been verified, exact setup remains pinned to 3.8.2, and the known
provenance mismatch still blocks evidence-dependent work. Automatic code changes
remain unavailable until supported no-PAT Copilot authentication, matching setup,
and provenance are approved and verified. This is not end-to-end automation yet.

Offline regression: run scripts/Test-MaintenanceRelease.ps1. Its NuGet requests
are mocked; it checks numeric ordering, prerelease filtering, retained-project
selection, no-downgrade behavior, the package allowlist and feed failure handling.
maintenance-validation.yml runs it alongside the existing harness checks.

## Verified Test Results

- Hosted harness validation and all 13 retained application builds passed:
	https://github.com/hossnrabbit/active-directory-aspnetcore-webapp-openidconnect-v2/actions/runs/44405120148.
- ADO pipeline 3154 dry-run 1724129 passed. Its published dispatch-results.json
	contains exactly this fork, test branch, workflow and Microsoft.Identity.Web.UI
	3.8.2, with no live dispatch.
- Live ADO retry 1724909 reached GitHub but received HTTP 403 using the existing
	dispatch credential. No successful workflow dispatch, release issue,
	deduplication replay or Copilot session has been demonstrated.
- Hosted source setup 44405120153 failed closed on both exact versions:

| Version | NuGet Repository Commit | Exact Tag Commit |
| --- | --- | --- |
| 3.8.2 | 99ab1ad7b5d47fe3160422b7360e27f6961185d1 | 0a5b6114fdd1d76128438df01ccb09a6f9834c30 |
| 3.7.0 | a27e03a753cc736080cd4497de77da03bfb1570f | 9bd521186bf9b00a2af4fc920be8c7f87683a012 |

This is NOT end-to-end success or merge readiness. The ADO path still requires a
dispatch credential with access to the fork; GitHub-only discovery avoids that
boundary. The provenance mismatch still needs an explicitly
reviewed resolution. Do not bypass the check, substitute source, change the
default branch or alter approvals. The baseline diagnostic never replaces the
failed target evidence. All original PRs and default branches remain unchanged.

This opt-in harness belongs to
Azure-Samples/active-directory-aspnetcore-webapp-openidconnect-v2, targeting master.
It is a separate change from cleanup PR #831 and can operate on either layout.
It changes no sample source, dependency versions, app registrations or credentials.

## Scope

scripts/maintenance-samples.json inventories 22 original projects: 13 eligible
IdWeb applications, four support UI-test projects and five excluded B2C/sovereign
projects. Excluded files may disappear without breaking discovery. Missing
eligible/support projects and new uncataloged projects require review. The six
cataloged Microsoft.Identity.Web package IDs are dispatched individually; a
Microsoft.Identity.Client release is rejected, not mapped transitively to IdWeb.
Coordinated multi-package upgrades require explicit scope approval rather than
silently upgrading the entire IdWeb family or adding MSAL references.

## Activation

Merge/review this harness independently of the cleanup. An administrator must
explicitly configure MAINTENANCE_DISPATCH_ACTOR, MAINTENANCE_PACKAGE and
MAINTENANCE_TARGET_VERSION Actions variables on the upstream repository. The
package/version variables pin the next approved setup acquisition; dispatch must
match them. Keep one approved target in flight until its agent setup completes.
Do not change these variables underneath an active session. The agent checks its
original manifest against the assigned issue and blocks any mismatch.

After merge, manually dispatch release-maintenance.yml on master with package,
version, official release_notes_url and optional event_key. There is no schedule,
release subscription, ADO registry change or live dispatch in this PR. No actor is
enabled by default. Stable event keys are SHA256 of lowercase repository, '|',
lowercase package, '|', exact version. Open AND closed workflow-created release
issues are deduplicated. Set assign_copilot only after enabling the cloud agent
and storing COPILOT_ASSIGNMENT_TOKEN as an Actions secret. Use a user token with
GitHub's documented Copilot-assignment permissions for this repository; an
Issues-only token is not assumed sufficient. No secret value belongs in issues,
logs, source or sample configuration. Without assignment, a maintainer may inspect
the issue and explicitly assign sample-implementer later.

Workflow execution approval stays enabled according to existing repository policy.
Human merge approval is separate. This PR changes neither policy and does not
enable auto-merge. Fork PR workflows receive no assignment token. Hosted PR checks
may require maintainer approval; their existence is not proof they ran.

## Evidence And Execution

Copilot setup runs offline checks, discovers exact latest stable versions, downloads
official NuGet archives and fetches their recorded full IdWeb commits into ignored
.maintenance-evidence. It does NOT run SDK code or authenticate to a tenant.
NuGet package identity, official source URL, full commit and SHA256 are required
for target and baseline. Tags are advisory, never a substitute or blocker when a
verified NuGet commit exists. Preview/floating versions and SDK main are unsupported.

The immutable manifest records original project references/frameworks, package
hashes, source commits and full src/tests comparison hashes per baseline. The
planner reads bounded relevant source/contracts/tests and discovers improvements
across the entire range. The implementer applies only justified scoped edits and
invokes the independent read-only reviewer. AGENTS.md defines the required matrix,
role handoffs, one-repair/two-review budget and blocked/partial outcomes. Manifest
immutability is checked for accidental changes; it is not a cryptographic sandbox
against an agent able to edit its own workspace. Human diff review remains required.

Run offline checks with PowerShell 7:

```powershell
./scripts/Test-Maintenance.ps1
./scripts/Validate-Maintenance.ps1
```

An actual update additionally requires ORIGINAL evidence validation:

```powershell
./scripts/Validate-Maintenance.ps1 -CoordinatedManifest $env:MAINTENANCE_COORDINATED_MANIFEST -Build
```

Only on an approved hosted build machine, add -Build to build all 13 retained
applications. maintenance-validation.yml provides those hosted builds and offline
regression checks; the existing .NET solution workflow remains unchanged. This
harness PR has not run local builds/restores, downloaded packages/source evidence,
retrieved secrets, provisioned identities, dispatched a release or performed live
authentication. Live sign-in, Graph calls, caching, authorization, claims challenges
and existing UI tests remain NOT RUN automatically and require approved test
identities and a separately reviewed basic-flow test recipe. Static/build checks
alone are not end-to-end rollout acceptance or grounds for automatic merging.