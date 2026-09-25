---
name: apps
description: 'Build, modify, debug, and validate application features, especially Flutter apps. Use when implementing screens, widgets, state, navigation, persistence, responsive UI, or user-facing app behavior.'
argument-hint: 'Describe the app feature, bug, or workflow to implement'
user-invocable: true
---

# Application Development

## When to Use

Use this skill for app work that changes user-facing behavior or the code supporting it, including:

- Flutter screens, widgets, layouts, themes, navigation, and accessibility
- Local state, async flows, persistence, and user interactions
- Responsive behavior across mobile, desktop, and narrow layouts
- Debugging a visible app defect or a failing widget/integration test
- Small app refactors needed to make a feature testable or maintainable

## Procedure

1. **Identify the product behavior.** Restate the requested outcome in concrete terms: what the user sees, does, or can no longer do. Find the nearest screen, widget, state holder, service, or test that directly controls it. Avoid broad repository mapping.
2. **Form a local hypothesis.** Name the likely controlling code path and one cheap check that could disconfirm it, such as a neighboring widget test, a targeted search, analyzer output, or reproducing the interaction.
3. **Inspect local conventions.** Read the owning implementation and its nearest call sites/tests. Preserve the existing architecture, naming, theme, dependency choices, and public APIs unless the feature requires a change.
4. **Choose the smallest complete slice.** Implement the behavior end to end, including loading, empty, error, disabled, and success states where the workflow can encounter them. Keep layout dimensions stable and make controls accessible with meaningful labels and semantics.
5. **Add or update focused tests.** Prefer widget tests for interaction and rendering behavior, unit tests for pure logic, and integration tests only for cross-screen or platform workflows. Cover the changed behavior and its important boundary cases.
6. **Format and validate immediately.** Run the narrowest useful checks first, then broaden as needed:
   - `dart format` on changed Dart files
   - `flutter analyze`
   - focused `flutter test <path>` and then the full test suite when the change is shared
   - a debug build or platform-specific check when build configuration or assets changed
7. **Exercise the running app when available.** Use hot reload for Dart/UI-only changes and hot restart when initialization, dependency injection, or persistent state setup changed. If no app is connected, report that runtime verification was unavailable.
8. **Review the final diff.** Confirm no generated files, secrets, unrelated formatting, or unnecessary dependencies were added. Check that asset and platform changes are declared correctly and that the implementation works at the smallest supported viewport.

## Decision Points

- **UI-only change:** update the owning widget, add a focused widget test, format, analyze, test, and hot reload.
- **State or async change:** identify the state owner and lifecycle, model loading/error/empty states, test success and failure paths, and hot restart if startup wiring changed.
- **Navigation change:** trace the route registration and both source/destination flows, then test navigation and back behavior.
- **Persistence or platform change:** inspect the existing adapter/package first, keep platform-specific code isolated, and validate on the affected platform when available.
- **Responsive layout issue:** reproduce at the failing size, prefer constraints and flexible layout over hard-coded overflow-prone dimensions, and verify both narrow and wide views.
- **Unclear request:** ask one concise question only when the desired behavior or target platform cannot be inferred from nearby code or the request.

## Completion Checklist

- The requested user-visible behavior is implemented at its controlling code path.
- Changed states and failure paths are handled deliberately.
- Focused tests cover the new or corrected behavior.
- Formatting, analyzer, and relevant tests pass, or failures are explicitly reported.
- Runtime verification was performed with hot reload/restart when a connected app was available.
- The final diff is scoped, and no generated or unrelated files were changed.
