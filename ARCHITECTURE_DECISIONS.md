# Architecture Decision Records — LeaseLens

This log records the core engineering decisions behind LeaseLens, written for
technical reviewers. Each entry follows Context / Decision / Consequences and
is kept deliberately concise. The system pairs Meta AI models (Baseten-hosted
Muse Spark for reasoning, Meta SAM 3.1 for segmentation, Muse Voice for
transcription) with a deterministic Python verification core.

---

## ADR-01: Deterministic Python owns statutory math and verbatim verification

**Status: Accepted**

**Context.** A lease auditor that invents a clause or a statute is worse than
useless — it can mislead a tenant in a real legal dispute. LLMs hallucinate
quotes and citations, and their arithmetic is unreliable.

**Decision.** The LLM only proposes. Deterministic Python owns every
consequential computation: the § 551 BGB deposit cap (3× monthly net rent),
all deposit arithmetic, verbatim substring verification of every flagged
quote against the extracted lease text, and validation of every citation
against `jurisdictions/registry.json`. Anything unverified is never shown.

**Consequences.** A zero-hallucination guarantee for displayed findings, at
the cost of occasionally dropping a true but unverifiable flag.

## ADR-02: Glyph-level PDF highlight localization via CID widths and TJ offsets

**Status: Accepted**

**Context.** Judges and tenants must see exactly which words in the original
lease were flagged. Coarse line- or block-level heuristics misplace
highlights on multi-column layouts, justified text, and tightly kerned
embedded fonts — undermining trust in the evidence view.

**Decision.** We parse each embedded CID font's `/W` advance-width array and
walk the content stream's `TJ` arrays, accumulating per-glyph offsets
(including kerning adjustments) to anchor every verified quote to its exact
glyph positions. Highlights are drawn at glyph precision on the rendered
page.

**Consequences.** Pixel-accurate, court-presentable highlighting, in exchange
for a hand-maintained PDF parser that must handle unusual font encodings
defensively.

## ADR-03: SAM 3.1 specificity guard and narration-steered keyframe prompts

**Status: Accepted**

**Context.** In walkthrough videos, a generic prompt such as "damage" can
make SAM 3.1 segment most of the room, producing evidence masks that prove
nothing. Unsteered per-frame prompting is also expensive and inconsistent
across frames.

**Decision.** Two safeguards: a 60% frame-area specificity guard rejects any
mask covering more than 60% of the frame as non-specific, and keyframe
prompts are steered by the Muse Voice narration transcript, so the frame
where the tenant says "here is the burn mark" is segmented for that object.

**Consequences.** Masks stay tight, attributable, and cheap to produce;
genuinely room-filling damage must be captured as a still photo instead.

## ADR-04: Translation + uniform-scale registration with a +0.20 IoU zoom gate

**Status: Accepted**

**Context.** Move-out photos are taken from a different position than move-in
photos. A naive comparison mistakes camera reframing for damage growth — a
scaled copy of the original mask can mimic a grown defect almost perfectly.

**Decision.** A joint solver searches 2D translation and uniform scale
(Δx, Δy, s) to align the move-in mask to the move-out frame. A non-1.0 scale
is accepted only when its exact IoU beats the best translation-only fit by
at least +0.20; otherwise the translation fit stands and the size
difference is reported as measured.

**Consequences.** Reported damage growth reflects physical change rather
than camera movement, with an explicit, testable acceptance threshold.

## ADR-05: Zero-dependency Reed–Solomon GF(256) QR encoder for LAN handoff

**Status: Accepted**

**Context.** Tenants photograph rooms on their phones, but routing private
photos through a cloud relay is a privacy and reliability liability, and
adding a QR library dependency for one feature is unjustified weight.

**Decision.** We hand-rolled a QR encoder — byte-mode encoding, Reed–Solomon
error correction over GF(256), mask evaluation — with zero external
dependencies. It renders the local-network upload URL as a QR code so the
phone joins the tenant's own LAN and uploads directly to the laptop running
LeaseLens.

**Consequences.** The handoff works fully offline with no third-party data
exposure; the encoder is covered by algebraic and unit tests instead of
upstream maintenance.
