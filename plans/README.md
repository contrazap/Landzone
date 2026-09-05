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

`F02_ranged_combat_and_first_enemy.md` is the active plan. Its preflight is recorded there and
in `PROGRESS.md`; implementation must proceed one requested step at a time. The completed F00
and F01 plans remain the foundation and regression baseline.
