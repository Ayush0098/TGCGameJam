# MVP fresh-player check

Status (2026-10-04): user explicitly deferred the three-player production gate.
This checklist remains available for user/roommate/friend feedback; no results
or gate pass are recorded. It does not block current production. The separate
art/voice study is at `/reference/index.html`; test puzzle rules in the root MVP.

Current build contains **Nap Time (page 2)**, **Midnight Snack (page 4)** and
**The Boss's Birthday (page 6)**. Nap Time now has integrated artwork, animation and voice auditions; pages4/6 remain greybox. The remaining
levels and integrated final presentation are not implemented yet. A separate
painted/SVG animation and voice reference has been produced and revised.

Two movable lanterns illuminate circular areas with a visible reveal boundary.
Characters carry an idea glow after activation; this glow does not reveal other
thoughts or illuminate objects. Thoughts disappear completely outside light.

## Run the session

1. Launch a fresh browser session for each tester. Let them watch the Originals.
2. Give only the general controls: drag a HUD hook into the
   scene, reposition its lantern, return it to a hook to park it, swap lit thought bubbles, ACTION,
   REWIND and RESTART. Do not explain the puzzle solutions.
3. On page 6, before ACTION, ask which way a lit character will move on beat 1
   (left, right, or stay). Record the prediction before playback, then its result.
   Use several predictions across the session; keep the total number recorded.
4. Record the page 6 **Attempts** number when they first win. RESTART does not
   erase attempts. If they skip or stop without winning, record that explicitly.
5. Record their visible or spoken reaction when the lamp chain happens. Ask
   what they understood and where they were confused after the session.

Someone already shown the solution is not a fresh tester for this check.
Use a desktop or laptop with the game reasonably large, preferably 1280×720.

Nap Time is already fully lit, with both lanterns parked. Midnight Snack starts
with one lantern placed and one parked; its placement area ends before the
kitchen lamp's zone, preserving the lamp chain. Birthday likewise starts with one
placed and one parked, and permits placement across the room. ACTION locks both
lights; REWIND restores the edited positions and RESTART restores their defaults.
This checkpoint has no light-blocking obstacles yet.

## Results to report

| Tester | Page 6 runs to first win (or unsolved) | Correct predictions / total | Chain reaction observed | Confusion or bugs |
|---|---|---|---|---|
| You  | | | | |
| Roommate | | | | |
| Friend | | | | |

The gate passes only with at least three fresh players, a median of **five
runs or fewer**, **80% or more** correct first-move predictions, and evidence
of a visible or audible reaction to the chain. Report the prediction numerator
and denominator, not just a percentage. Unsolved/skipped sessions need follow-up;
do not drop them from the result to make the gate pass.

Automated tests verify rules and controls; they do not measure this gate.
