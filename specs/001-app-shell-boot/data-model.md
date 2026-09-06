# Phase 1 Data Model: App Shell Boot

**N/A** — this feature introduces no data entities. `KristleApp` is a stateless
presentation widget with two constructor parameters (`wordList`, `enableAnswerReveal`)
that it passes through to `GameScreen`; it owns no state of its own and persists nothing.
Entity modeling begins with later roadmap features (e.g. #2 Word list loading, #14 Game
statistics model).
