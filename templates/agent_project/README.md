# Agent-built project starter

Use this starter to build a game or application through on-demand feature plans and agent-owned
deliveries, then study its implementation through a maintained code guide. It supplies process
documents, not runtime code, a test framework, or a preselected architecture.

Files here are inert starter material for a different project. AGENTS.md.template intentionally
does not act as instructions for agents editing this template inside Landzone.

## Set up a project

1. Choose an empty destination directory or an existing project to adapt. Copy this folder's
   contents there, excluding this setup README if the project already has its own README.
   Do not overwrite existing work blindly; reconcile instructions and documents when adapting.
2. Copy AGENTS.md.template to AGENTS.md in the destination. Treat this README as setup guidance;
   produce a project README describing purpose, actual run commands and document links.
3. Give the agent your idea using the bootstrap prompt below. It fills the documents from your
   request and actual environment, removes unused prompts, and identifies only material open
   scope decisions. Do not copy Landzone's content, engine paths, feature IDs or history.
4. Once the product scope and stack are settled, ask Generate the next plan. Then ask Implement
   the plan. Repeat for each feature or substantial delivery until the defined product is done.

## Bootstrap prompt

```text
Set up this project using the agent_project starter workflow.

My idea and intended users:
[Describe the idea, main user journey, and what a useful finished first version means.]

Technology and target platforms:
[Required stack/engine and platforms, or ask for a recommendation.]

Constraints and exclusions:
[Local/offline or hosted, assets, dependencies, budget, scope exclusions, data/privacy needs.]

Inspect the actual directory and available tools. Customize the product brief, roadmap,
agent instructions, verification profile, progress ledger, plan template and study documents.
Propose reasonable defaults for routine details; ask only about material unresolved scope.
Do not implement application code or generate future detailed feature plans during setup.
Do not initialize Git, commit, push, publish, or provision external services unless I ask.
I will request plans on demand, then ask you to implement each planned delivery. Default to
whole features; split only for substantial integration or verification boundaries. You own
verification and fixes during implementation. Do not require me to run manual checks.
Maintain a code guide with actual files and runtime flows so I can study the result later.
```

## Included documents

| File | Customize for the new project |
| --- | --- |
| [AGENTS.md.template](AGENTS.md.template) | Agent contract; install as AGENTS.md |
| [PROGRESS.md](PROGRESS.md) | Current state and exact next action |
| [docs/PRODUCT.md](docs/PRODUCT.md) | Audience, first complete scope, rules and exclusions |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Ordered feature outcomes and dependency boundaries |
| [docs/CONTENT_CATALOG.md](docs/CONTENT_CATALOG.md) | Optional finite authored content; remove if unnecessary |
| [docs/VERIFICATION.md](docs/VERIFICATION.md) | Locally confirmed stack/tools, commands, scenarios and evidence |
| [plans/FEATURE_PLAN_TEMPLATE.md](plans/FEATURE_PLAN_TEMPLATE.md) | Feature/delivery planning and acceptance record |
| [docs/CODE_GUIDE.md](docs/CODE_GUIDE.md) | Actual system map and learning walkthroughs |
| [docs/ARCHITECTURE_EVOLUTION.md](docs/ARCHITECTURE_EVOLUTION.md) | Material design decisions and alternatives |

Keep the roadmap high level. Do not fill all detailed plans during bootstrap. There is no fixed
feature count: use enough cohesive outcomes to deliver the approved first version. The final
feature must include platform-appropriate packaging/release verification and guide consolidation.
Record unavailable tooling honestly; a generic profile is not evidence that checks ran.

## Everyday prompts

- Check status: read-only one-line handoff.
- Check next step: explain the next action without changing files.
- Generate the next plan: create only the next feature plan.
- Implement the plan: finish its next delivery, normally the entire feature.
- Continue implementation: resume an interrupted delivery.
- Verify: execute relevant checks and update/report evidence without starting new features.
- Explain the [system] implementation: use the current code guide and actual code.

Human feedback is optional. Required behavior, rendering, data integrity and release checks
still need evidence. Record subjective qualities that cannot be established without human
observation separately; do not make them acceptance homework or claim them as verified.
