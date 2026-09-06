# Phase 1 Data Model: On-Screen Keyboard (Static)

## GameKeyboard (widget)

| Property | Type | Description |
|---|---|---|
| `onLetterTap` | `ValueChanged<String>` | Invoked with the tapped letter (FR-003). |
| `onBackspaceTap` | `VoidCallback` | Invoked when backspace is tapped (FR-004). |
| `onEnterTap` | `VoidCallback` | Invoked when the submit control is tapped while enabled (FR-007). |
| `canSubmit` | `bool` | Whether the submit control is currently enabled (FR-006). |
| `keyStatuses` | `Map<String, LetterStatus>` | Per-key status for coloring; out of scope for this feature (defaults to empty, all keys render the single default color per FR-008). |

**Layout**: Three fixed rows — `QWERTYUIOP`, `ASDFGHJKL`, `ZXCVBNM` + backspace — laid
out with a `LayoutBuilder`-computed key size per Phase 0 research, plus a submit control
below the rows (FR-001, FR-002, FR-005, FR-009).

**Rendering rules**:

- Every letter key uses the same single default background color (FR-008) — this
  feature does not read `keyStatuses` to vary key color.
- The submit control's `onPressed` is `canSubmit ? onEnterTap : null`, which both
  disables it and reports submit taps when enabled (FR-006, FR-007).

**State transitions**: None — `GameKeyboard` holds no state of its own; it is a pure
function of its constructor parameters, re-rendering whenever `canSubmit` (or, in a
later feature, `keyStatuses`) changes.

**Relationships**: Consumed by the core play loop (later roadmap feature), which
supplies live callbacks wired to guess entry/backspace/submission and computes
`canSubmit` from the current guess length. Key-status coloring (later roadmap feature)
will supply a non-empty `keyStatuses` map; `GameKeyboard` itself has no dependency on
either.
