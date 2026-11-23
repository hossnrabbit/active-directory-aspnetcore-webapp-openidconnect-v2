# IdWeb Sample Maintenance Harness

## Retired Test Entry Point

The SDK-specific release entry point on this test branch is retired. Its issue
job is permanently disabled, its schedule removed, and its token is read-only.
Use the ONE shared harness in `hossnrabbit/ms-identity-docs-code-dotnet` on
`test/msal-harness-e2e` for releases from either MSAL.NET or IdWeb. The name of
that branch is retained for compatibility; it is no longer MSAL-specific.
The historical integration details below do not activate a second update path.
Original upstream PRs, default branches, and sample dependencies are unchanged.

## Test Branch Override

This checkout is an isolated integration test in
hossnrabbit/active-directory-aspnetcore-webapp-openidconnect-v2 on
test/idweb-harness-e2e. The upstream deployment instructions below describe the
original harness PR, not this test's activation. Only hossnrabbit may dispatch
this branch. Manual execution remains pinned to Microsoft.Identity.Web.UI 3.8.2;
discovery may report newer stable UI releases without approving execution.
The companion ADO branch is test/idweb-pipeline-e2e in
IdentityDivision/DevEx/msal-sdk-sample-maintenance. Its only enabled destination
is this fork/test branch. Push runs the hosted harness checks and exact source
setup; it does not create an issue or assign Copilot. The release workflow also
has a branch-scoped push registration event whose issue job is deliberately
skipped; test-branch issue creation requires workflow_dispatch. No default branch,
upstream PR, secret, actor variable or approval policy is changed for this test.
Copilot's automatic import of custom setup from a non-default branch is NOT
assumed proven by a successful standalone setup run. Assignment remains optional
and requires separate eligibility/secret configuration; never fall back upstream.

## GitHub-Only Discovery Test

MSAL.NET discovery is separate: `hossnrabbit/ms-identity-docs-code-dotnet` on
`test/msal-harness-e2e` checks `Microsoft.Identity.Client` against its five
direct-MSAL samples. This fork checks `Microsoft.Identity.Web.UI`; do not route
MSAL releases into IdWeb updates or add direct MSAL references here.

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

Copilot setup runs offline checks and, only for the configured exact package/version,
downloads official NuGet archives and fetches the exact IdWeb version tags into
ignored .maintenance-evidence. It does NOT run SDK code or authenticate to a tenant.
NuGet repository commit metadata must equal the corresponding tag commit for both
the target and every applicable baseline. A missing historical tag or mismatch
blocks the ENTIRE setup; this initial harness deliberately has no partial-baseline
fallback. Preview/floating versions, SDK main and source substitution are unsupported.

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
./scripts/Validate-Maintenance.ps1 -EvidenceManifest .maintenance-evidence/manifest.json -ExpectedVersion <exact-version>
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