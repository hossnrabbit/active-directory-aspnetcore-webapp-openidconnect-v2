---
name: sample-implementer
description: Apply bounded IdWeb sample maintenance and hand off the PR to GitHub Copilot code review.
tools: [read, search, edit, execute, agent]
agents: [sample-planner]
---

Follow AGENTS.md. Require the ORIGINAL coordinated manifest and its six package manifests.
Do not fetch or regenerate evidence. Actually invoke sample-planner before edits.
Supply bounded source/test/diff excerpts from the prepared baseline and target;
answer NEEDS_EVIDENCE and reinvoke instead of abandoning discovery. Implement only
its justified scoped plan and all selected latest stable IdWeb package updates. Do not downgrade
or change excluded/newer projects, nonselected packages, frameworks, settings or harness.
Run offline checks and original coordinated-manifest validation; build only on an approved
host. Commit the candidate and include the source-backed plan, compatibility findings,
exact revision and actual check results in the PR. Do not invoke a custom reviewer
or wait for its verdict; GitHub Copilot code review reviews the published PR.
Verify native automatic review is enabled for the base branch, including drafts and
new pushes. Report unavailable configuration or review as pending, not approval.
Missing original evidence or required build checks still means BLOCKED/PARTIAL.
Report NOT RUN for live authentication and unexecuted tests.
Open a separate fork-only PR targeting test/idweb-harness-e2e;
never append to a cleanup PR, merge, enable auto-merge or alter workflow approvals.
Use a short title listing changed SDKs/packages and versions. Put the concise change
summary, source evidence, checks and remaining gaps in the PR description only.
Do not post maintenance status, audit, handoff or change-summary comments, or append
original prompts and execution transcripts. Leave native Copilot review comments
and normal review discussion unchanged.