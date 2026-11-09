# LeaseLens Roadmap

LeaseLens v1.0 was submitted to the Meta Global AI Developer Hackathon
(Team Shamas, Indie Developer Track). This roadmap covers the next-phase
engineering milestones toward a production service for international
students and expats. Dates are intentionally not promised; milestones ship
in the order below.

---

## v1.1 — Student Dorm Launch (Dresden / Germany)

**Scope.** Make LeaseLens a first-class tool for the German student-dorm
market, its highest-volume audience. The handover step gains native support
for the paperwork German tenants actually sign: standardised
*Wohnungsübergabeprotokoll* forms and the lease templates used by
*Studierendenwerk* housing providers, so a Dresden dorm tenant can go from
PDF lease to signed-condition evidence without any manual form mapping.

**Deliverables**

- DIN A4 *Wohnungsübergabeprotokoll* generator: room-by-room condition
  entries mapped onto the standard German handover form layout, exportable
  as a print-ready PDF.
- *Studierendenwerk* lease template pack: pre-verified clause patterns and
  statutory references for common dorm contract clauses (pauschal rent,
  Kaution, Schönheitsreparaturen).
- German-language UI pass for Step 2/3 evidence flows (findings text stays
  bilingual per the existing language rule).
- Dorm-specific demo preset replacing the generic German sample.
- Onboarding flow for dorm move-in day: guided photo checklist per room.

## v1.2 — 8-DOF Planar Homography Registration

**Scope.** Upgrade the Step 3 move-out comparator from the current 2D
translation + uniform-scale solver (Δx, Δy, s) to full 8-DOF planar
homography. Tenants rarely reproduce the move-in camera angle; steep 3D
perspectives currently defeat planar alignment and inflate or hide measured
damage change. RANSAC-based homography estimation (OpenCV, with a Kornia
path evaluated for GPU batches) will align move-in masks to move-out frames
with sub-pixel precision, while keeping the +0.20 IoU zoom gate from ADR-04
as the acceptance test so reframing is still never reported as growth.

**Deliverables**

- Feature-matching pipeline (keypoints + descriptors) between move-in and
  move-out frames, robust to lighting change.
- RANSAC homography solver with inlier reporting; fallback to the existing
  (Δx, Δy, s) solver when inliers are insufficient.
- Warped-mask IoU comparator with sub-pixel area measurement and updated
  residual-growth reporting.
- Regression suite built from angled photo pairs, including steep-angle
  cases the current solver is known to fail.
- ADR-06 documenting the solver change and its acceptance thresholds.

## v2.0 — Live AR Camera Viewfinder Overlay

**Scope.** Close the loop on move-out day itself: instead of aligning two
photos after the fact, help the tenant take the *right* photo. The saved
Day-1 SAM 3.1 mask is projected directly over the live mobile camera feed
(WebRTC `getUserMedia`), so the tenant can match the original framing in
real time — same angle, same distance — before pressing the shutter.
Perfectly aligned pairs make the comparator's verdict close to
measurement-grade and remove most "camera movement" disputes entirely.

**Deliverables**

- WebRTC viewfinder in the mobile handoff flow, served over the existing
  local-LAN QR pairing (no cloud relay).
- Live overlay rendering of the Day-1 mask with opacity and edge modes,
  plus a framing-match indicator driven by real-time feature alignment.
- Capture-time quality gates: blur, glare, and angle-deviation warnings
  before the photo is accepted.
- On-device fallback: overlay works with the v1.2 homography estimate when
  live tracking loses lock.
- Updated Handover Protocol PDF noting "framing-matched capture" for pairs
  taken through the viewfinder.
