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

`F00_project_foundation.md` is the active plan. Its environment preflight is recorded there and
in `PROGRESS.md`; implementation must proceed one requested step at a time.
