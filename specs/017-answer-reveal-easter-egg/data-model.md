# Phase 1 Data Model: Answer-Reveal Easter Egg

**N/A** — this feature introduces no persisted or shared data entities; it adds
transient UI counters (`_headerTapCount`, `_answerTapCount`, `_isAnswerRevealed`) local
to `GameScreen`'s state, reset by the "New Game" flow (item 13), and a single
compile-time constant (`AppConfig.enableAnswerReveal`).
