---

description: "Task list template for feature implementation"
---

# Tasks: App Shell Boot

**Input**: Design documents from `/specs/001-app-shell-boot/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md) (N/A — no entities), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
This feature targets an already-existing implementation ([lib/main.dart](../../lib/main.dart)),
so per ROADMAP.md's rules, tasks add the missing test coverage but MUST NOT change
application code — the new test is written against current behavior and is expected to pass
as written.

**Organization**: This feature has a single user story (P1), so all implementation tasks sit
in one phase.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1)
- Include exact file paths in descriptions

## Path Conventions

Single Flutter project: `lib/` (source), `test/` (tests) at repository root — per
plan.md's Structure Decision. No `src/`, `backend/`, or platform-specific test trees apply.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the project structure this feature depends on already exists — no new
scaffolding is created.

- [X] T001 Verify `flutter pub get` succeeds and `flutter analyze` is clean on the current
      working tree (repository root), per Constitution's Development Workflow.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: N/A for this feature — `KristleApp` has no shared infrastructure dependency
beyond the Flutter SDK itself, which Phase 1 already confirms is available.

**Checkpoint**: No foundational work required; proceed directly to User Story 1.

---

## Phase 3: User Story 1 - App launches to a themed shell (Priority: P1) 🎯 MVP

**Goal**: Confirm the app boots directly into a single `MaterialApp` root titled "Kristle",
themed via `ColorScheme.fromSeed(seedColor: Colors.green)` with `useMaterial3: true`, and
that this is locked in by a test (FR-001–FR-005, SC-001–SC-003).

**Independent Test**: Run `flutter test test/app_shell_test.dart` — it pumps `KristleApp`
standalone (with a minimal test `WordList`) and asserts the title and theme without touching
any other feature's widgets.

### Tests for User Story 1 ⚠️

> **NOTE**: `KristleApp` and `main()` already exist in
> [lib/main.dart](../../lib/main.dart) — this is coverage for existing behavior, not new
> implementation. Write the test, run it, and confirm it passes against the current code
> (per ROADMAP.md: "Every new test MUST pass as written, since it's written against behavior
> that already exists in the code"). If it fails, the spec/plan has drifted from reality and
> must be corrected — do not change `lib/` to make it pass.

- [X] T002 [US1] Create `test/app_shell_test.dart` with a `testWidgets` case that pumps
      `KristleApp(wordList: <minimal test WordList>)` and asserts: exactly one `MaterialApp`
      is found, its `title` equals `'Kristle'`, `theme.useMaterial3 == true`, and
      `theme.colorScheme.primary` equals
      `ColorScheme.fromSeed(seedColor: Colors.green).primary` (locks in FR-001–FR-005).
- [X] T003 [US1] Run `flutter test test/app_shell_test.dart` and confirm it passes as
      written; if any assertion fails, stop and reconcile spec.md/plan.md against the actual
      `lib/main.dart` implementation rather than editing `lib/`.

### Implementation for User Story 1

- [X] T004 [US1] Read [lib/main.dart](../../lib/main.dart) and confirm `KristleApp` matches
      spec.md's FR-001–FR-005 exactly (single `MaterialApp` root, no splash/loading widget,
      `title: 'Kristle'`, `ColorScheme.fromSeed(seedColor: Colors.green)`,
      `useMaterial3: true`, no gameplay logic in `KristleApp` itself). No code changes
      expected — this is a verification task, per ROADMAP.md's "`/speckit-implement` writes
      no application code" rule.

**Checkpoint**: User Story 1 is fully covered by `test/app_shell_test.dart` and verified
against the existing `lib/main.dart` implementation — no `lib/` changes made.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T005 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T006 Walk through [quickstart.md](quickstart.md)'s "Run it" and "Validate with tests"
      steps manually (or via `flutter run`) to confirm the shell behaves as documented.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: N/A — nothing to complete.
- **User Story 1 (Phase 3)**: Depends on Phase 1 (T001) only.
- **Polish (Phase 4)**: Depends on Phase 3 completion.

### Within User Story 1

- T002 (write test) → T003 (run test, confirm pass) → T004 (verify implementation matches
  spec). Sequential — no parallelizable tasks within this single-story feature (one test
  file, one verification pass).

### Parallel Opportunities

- None beyond T001, which has no dependents to block. This feature is small enough (one
  widget, one test file) that sequential execution is simpler and safer than coordinating
  parallel work.

---

## Implementation Strategy

### MVP First (and only) — User Story 1

1. Complete Phase 1: Setup (T001).
2. Complete Phase 3: User Story 1 (T002–T004) — this **is** the MVP; there is only one user
   story for this feature.
3. Complete Phase 4: Polish (T005–T006).
4. **STOP and VALIDATE**: `flutter analyze` and `flutter test` clean; manual `flutter run`
   matches quickstart.md.

---

## Notes

- No application code changes are expected anywhere in this task list — `lib/main.dart`
  already implements the app shell. If executing T004 reveals a mismatch with spec.md, fix
  the spec/plan, not `lib/`, per ROADMAP.md's implementation rules.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything except
  `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and `test/app_shell_test.dart`
  stay untracked (present on disk, not committed) even after this feature is done. Only this
  `specs/001-app-shell-boot/` directory's own files are trackable output of this task list
  today; `test/` and `lib/` are re-tracked together, for real, after feature #20.
