# Phase 1 Data Model: Win Celebration Overlay

**N/A** — this feature introduces no data entities; it adds transient timers
(`_winImageShowTimer`, `_winImageHideTimer`) and a derived boolean (`_showWinImage`)
triggered by the core play loop's (item 7) existing win detection, with no state that
outlives the celebration window or a new round.
