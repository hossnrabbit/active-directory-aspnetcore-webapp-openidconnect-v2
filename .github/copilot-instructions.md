# Repository Maintenance

Follow AGENTS.md for release tasks and scripts/maintenance-samples.json for scope.
This repository consumes IdWeb, not direct MSAL. Preserve existing authentication
flows, frameworks and configuration. Missing setup evidence is SETUP_BLOCKED.
Do not fetch replacement SDK evidence, run SDK code, retrieve secrets, or bypass
review/approval. Release implementation uses sample-planner for API compatibility
discovery and GitHub Copilot code review on the published PR; no custom reviewer
role is required. Keep build validation and human merge approval separate.

For code review, check the selected dependency versions and existing sample calls
against the exact old/new SDK source links and compatibility findings in the PR.
Check signature/default changes and successful, error and cancellation paths.
Do not infer runtime compatibility solely from a successful build or treat an
unexamined SDK path as evidence that no source change is needed.