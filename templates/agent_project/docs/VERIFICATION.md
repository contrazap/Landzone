# Verification profile

Status: Unconfigured. Fill from the actual project and locally confirmed toolchain during setup.
This profile does not itself prove that any command or automation exists.

## Toolchain and entry points

- Stack/engine/SDK and confirmed version:
- Source/project root and application entry point:
- Target platforms and packaging/deployment scope:
- Existing test/runtime/capture tools and how they were confirmed:
- Isolated test data/save location and cleanup constraints:

## Required command record

| Purpose | Exact command and working directory | Expected success and failure signals | Last actual result |
| --- | --- | --- | --- |
| Build/import/static validation | Fill from installed tools | Include errors, not only exit code | Not run |
| Startup smoke | Fill | Explicitly startup-only | Not run |
| Behavioral regression | Fill | Named assertions/scenarios and error review | Not run |
| Rendered/input verification | Fill or record missing capability | Captures inspected and real interaction paths | Not run |
| Packaging/runtime validation | Fill for release platform | Artifact executes and complete journey works | Not run |

Remove inapplicable rows with a reason. Do not invent commands or passing results. Features add
their own concrete scenarios and acceptance mappings, referring here for repeatable commands.

## Select a stack profile

Keep and customize only relevant guidance. Confirm exact commands against the local project and
installed version; use official documentation when necessary.

- Godot: engine import/parser checks, focused GDScript scenarios, real scenes/physics/input,
  a rendered capture method for changed presentation, and export plus exported-build execution.
  Headless state checks cannot prove the rendered result. Keep test saves isolated.
- Unreal Engine: record engine version, project file and target configuration; select appropriate
  C++ build or Blueprint compilation checks, runtime automation/functional scenarios, rendered
  interaction evidence and packaging/cook plus packaged execution. Projects differ: do not assume
  source builds, plugins, automation runners or a headless renderer are already configured.
- Web application: use existing package scripts for build/type/lint checks where available,
  focused data/API tests, and browser flows with rendered inspection at relevant viewport sizes.
  Exercise persistence and failures with isolated fixtures. Local verification does not authorize
  production deployment or sending real external messages.
- Other stack: identify native build/static tools, executable behavior checks, presentation
  inspection if applicable, data integrity/error cases and distributed-artifact verification.

## Evidence by risk

Reuse existing scenarios; do not add tests for every function or cosmetic property. Retain
persistent behavioral tests for durable state, resource/money ownership, permissions, critical
workflow transitions, deterministic algorithms and likely regressions as relevant to scope.
Exercise real input/runtime/API boundaries where direct method calls would miss integration bugs.
Use plain-data tests where they isolate important logic without unrelated runtime setup.

For visual changes inspect rendered output and record useful artifact paths. For data changes
exercise round trips, invalid/corrupt inputs, failures, recovery and compatibility as relevant.
Never use real user data for destructive fixtures. Check expected success markers, logs and
timeouts as well as exit codes; run relevant regressions and diff checks.

If an essential verification method is missing, establish safe in-scope tooling or leave a
required verification gap and the delivery incomplete/Blocked. Do not replace evidence with
code inspection alone or assign a user manual gate. Record subjective human qualities separately
as unassessed; they neither establish success nor excuse functional/rendering failures.
