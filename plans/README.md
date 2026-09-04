# Feature Plans

Feature plans are generated just in time from `FEATURE_PLAN_TEMPLATE.md`.

Rules:

- One file per roadmap feature: `F##_short_name.md`.
- Generate only the next dependency-satisfied feature.
- Inspect the real project and previous verification evidence before planning.
- Split work into independently requested steps.
- Implement only one step when the user asks for the next step.
- Keep later features and speculative final architecture out of the plan.
- Record actual evidence and deviations as implementation proceeds.

This folder intentionally contains no F00 plan yet. The next agent must inspect the local
environment before generating it.
