# Anchor — build plan and progress

Spec: [SPEC.md](SPEC.md). Stages are done strictly in order. A stage is ticked only
when `flutter analyze` is clean and `flutter test` passes. Decisions taken where the
spec was ambiguous are logged at the bottom.

Legend: `[ ]` to do · `[x]` done · `[~]` done with a note (see Decisions)

## Stage 1 — Foundation
- [x] 1.1 Project created (`GIGS/anchor`, bundle `com.anchorapp.anchor`), git init
- [x] 1.2 Dependencies in pubspec (riverpod, go_router, drift, google_fonts, flutter_local_notifications, timezone, audioplayers, home_widget, live_activities, path_provider, shared_preferences …)
- [x] 1.3 Folder structure: models, data, providers, screens, widgets, services, theme, assets
- [x] 1.4 Theme: colour tokens (dark + light), type scale (Space Grotesk / Inter / JetBrains Mono), radii, spacing
- [x] 1.5 Life areas: Startup, Cloud Learning, Side Gigs, Health, Personal — icon, label, grey/green tint
- [x] 1.6 Drift tables: Goals, Milestones, WeeklyTargets, Tasks, TimeBlocks, FocusSessions, EnergyCheckIns, Reminders (+ BrainDumps, Highlights, Settings/kv)
- [x] 1.7 Repositories over Drift
- [x] 1.8 Seed data on first launch (4 goals from spec, milestones, targets, tasks, blocks, past done history)
- [x] 1.9 go_router shell with 5 tabs
- [x] 1.10 Liquid glass bottom bar (blur, tint, hairline, sliding stretchy bubble, lemon icon, label fade, haptic, hide on scroll)
- [x] 1.11 Background grain / dot grid
- [~] 1.12 Floating streak bubble shell (left edge, draggable, remembers spot, hides on scroll, taps → Done)
- [x] 1.13 iOS: min iOS 16.2, Info.plist keys (notifications, background audio, NSSupportsLiveActivities)
- [x] 1.14 `codemagic.yaml` iOS → TestFlight with auto build number; widget-extension flag (off)
- [x] 1.15 Docs: README (Windows commands), CODEMAGIC_SETUP.md (owner steps)
- [x] 1.16 analyze + test green

## Stage 2 — Now screen and focus timer
- [x] 2.1 Card deck (PageView, peeking next card), huge title, tiny first step, monospace countdown
- [x] 2.2 Swipe up = complete (fly-off + haptic), swipe down = snooze
- [x] 2.3 Start button (lemon, anchored bottom)
- [x] 2.4 TimerService: presets 25/5, 50/10, 90/20, custom; pause/resume/stop; survives app background (wall-clock based)
- [x] 2.5 Full-screen timer view with draining CustomPainter ring
- [x] 2.6 Focus → break hand-off (hard stop); FocusSession saved
- [x] 2.7 Alarm sound asset (chime .caf + .wav), audioplayers playback, strong haptic
- [x] 2.8 "Up next" rail (next two blocks) at right edge
- [x] 2.9 Stuck? sheet: split into 5-min starter, swap for easier task, 5-min reset break
- [x] 2.10 Energy check-in card as first deck card when not done today (full UI; adaptation logic in Stage 5)
- [x] 2.11 Timer unit tests
- [x] 2.12 analyze + test green

## Stage 3 — Notifications and reminders
- [x] 3.1 NotificationService (flutter_local_notifications + timezone), iOS init
- [x] 3.2 Friendly permission explanation screen
- [x] 3.3 Timer-end notification: custom sound, time-sensitive interruption level
- [x] 3.4 Block-start alerts 5 min before
- [x] 3.5 Reminders with repeat rules (none, daily, weekdays, weekly) + reminder editor
- [x] 3.6 Morning check-in nudge, evening wrap-up, Sunday review
- [x] 3.7 Quiet hours (notifications shifted/suppressed)
- [x] 3.8 Re-schedule on app start / data change
- [x] 3.9 Tests for quiet-hours + repeat-rule logic
- [x] 3.10 analyze + test green

## Stage 4 — Today planner
- [x] 4.1 24-hour dial CustomPainter: hour ticks, labels, real-time lemon "now" hand
- [x] 4.2 Blocks as thick arcs by type
- [x] 4.3 Drag on ring to create arc; drag ends to resize; 15-min snap
- [x] 4.4 Centre: current block, remaining time, small Start
- [x] 4.5 Zoom 24h ↔ 6h window (pinch / double tap)
- [x] 4.6 Unscheduled task chips around ring, drag onto ring to schedule
- [x] 4.7 Tap arc → edit sheet (label, type, attach task, reminder, start timer, delete)
- [x] 4.8 Capacity ring (white → lemon → amber) + gentle overpacked note
- [x] 4.9 PlannerService auto-suggest (energy, estimates, priority, breaks) with animated preview, accept/edit
- [x] 4.10 Flat timeline toggle
- [x] 4.11 Planner unit tests
- [x] 4.12 analyze + test green

## Stage 5 — Energy check-in and adaptation
- [x] 5.1 Check-in UI: energy + mood 1–5, big emoji buttons, optional note (≈10 s)
- [x] 5.2 Low energy → lighter plan, shorter blocks, easy wins first
- [x] 5.3 High energy → hardest/most important first
- [x] 5.4 Daily top 3 picker + display on Now
- [x] 5.5 Several low days → kind support message + resources sheet
- [x] 5.6 Tests for adaptation + low-streak detection
- [x] 5.7 analyze + test green

## Stage 6 — Week and Goals
- [x] 6.1 Bento board layout
- [x] 6.2 Week-at-a-glance tile: 7 load bars, today lemon
- [x] 6.3 Weekly target tiles (%, thick bar, goal icon), long-press drag reorder
- [x] 6.4 Tiles: focus hours this week, tasks done this week, next milestone
- [x] 6.5 Target editor (3–5 per week, linked to goal)
- [x] 6.6 Sunday review story cards: done → carry over → pick next targets
- [x] 6.7 Goal constellation (InteractiveViewer), grouped by area, orbiting milestones, progress rings
- [x] 6.8 Drag nodes, layout persisted
- [x] 6.9 Goal detail full-screen sheet (why, milestones, targets, tasks, progress timeline)
- [x] 6.10 Carousel toggle
- [x] 6.11 Goal / milestone / task editors and linking
- [x] 6.12 Progress computation tests
- [x] 6.13 analyze + test green

## Stage 7 — Done and insights
- [x] 7.1 Heat map (last ~6 months), tap day → card stack
- [x] 7.2 Gentle streak logic (pause not reset, 1 rest day/week, best ever) + tests
- [x] 7.3 Streak bubble wired to real data, count-up on open; big streak + best on Done
- [x] 7.4 Streaks by life area: current, best, 30-day bar, "On fire", "Needs attention" + one-tap schedule
- [x] 7.5 Sunday summary card
- [x] 7.6 Done stack scrubber by day/week/month with totals
- [x] 7.7 Highlights (big wins) card + mark as highlight
- [x] 7.8 Gentle trends: focus hours/week, energy over time (smooth lines)
- [x] 7.9 analyze + test green

## Stage 8 — Extras
- [x] 8.1 Brain dump quick capture available anywhere + inbox to sort into tasks
- [x] 8.2 Focus guard: end-of-block reminder, optional distraction log
- [x] 8.3 Settings screen (theme, timer defaults, quiet hours, notification toggles, rest day, healthy hours limit)
- [x] 8.4 JSON export (share sheet) + import (with confirm) + round-trip test
- [x] 8.5 analyze + test green

## Stage 9 — Widgets and Live Activities (behind flag)
- [x] 9.1 App Group id in one place; data pushed via home_widget
- [~] 9.2 Swift WidgetKit extension: Now card, Top 3, Weekly targets (compiles only on Codemagic's Mac)
- [~] 9.3 Live Activity (lock screen + banner, no Dynamic Island design) via live_activities (same)
- [x] 9.4 Extension Info.plist, entitlements (app + extension)
- [x] 9.5 Ruby `xcodeproj` script adding the target in Codemagic pre-build, behind `ENABLE_WIDGETS`
- [x] 9.6 Apple Developer portal steps documented (App IDs, App Group, capabilities)
- [x] 9.7 Main app builds with flag off; analyze + test green

## Stage 10 — Polish and testing
- [x] 10.1 Motion pass: shared elements, springs, staggered entrances, ≤400 ms, reduced motion
- [x] 10.2 Haptics pass
- [x] 10.3 Accessibility: text scaling, Semantics labels, contrast check
- [x] 10.4 Dark + light pass on every screen
- [x] 10.5 Final planner + timer tests, full test run
- [~] 10.6 Codemagic final check + TestFlight runbook (config checked; first real build needs the owner's Apple/Codemagic setup)

## Decisions (where the spec was ambiguous)
- Project lives at `GIGS/anchor`, separate from Uniflex, with its own git repo.
- Bundle id `com.anchorapp.anchor`, set in `ios/Flutter/AppConfig.xcconfig`; Dart and
  codemagic.yaml must match (checked by `tool/check_bundle_id.sh` on every build).
- Fonts are bundled (assets/google_fonts) and google_fonts runtime fetching is off, so
  the app makes no network calls.
- Light theme: pure lemon stays the fill colour (buttons, progress); thin lines and
  accent text use a deeper lemon (#5C7400, 4.8:1 contrast) because #D4FF3A on off-white is unreadable.
- Gentle streak rules (1.12, logic in `services/streak_service.dart`): one free rest day
  per Mon–Sun week; other missed days pause the count; after more than 3 paused days in
  a row the next active day quietly starts a new run (best is kept). Today never counts
  as missed. The streak bubble shows real data now; the count-up is 400 ms.
- "AI outfit search system" goal is filed under the Startup life area.
- Unfinished tasks from earlier days roll forward into today silently (nothing is ever
  "overdue").
- Weeks run Monday–Sunday so the Sunday review closes the week.
- iPhone only, portrait only (no iPad layouts to maintain or screenshot for review).
- The alarm chime is synthesised (C6–E6–G6, 2.2 s) and bundled as `chime.caf` in the
  Runner target and `chime.wav` for in-app playback.
- Now deck order (`services/deck_order.dart`): task in the block happening now → top 3 →
  tasks in later blocks → priority; snoozed tasks wait at the back until their time.
- Swipe down snoozes for 1 hour, or to tomorrow 09:00 if that would pass 21:00. Every
  complete/snooze has Undo.
- The card's big countdown shows the time left in its block while that block is running,
  otherwise the task's estimate.
- Focus ends → break starts automatically at the exact end time (hard stop). Ending a break
  early needs a 1.2 s press-and-hold, so rest is protected but not a trap.
- "Shrink it" runs a 5-minute focus with no break, then returns to the deck.
- The bar and streak bubble fade out while the full-screen timer is showing.
- Smallest supported screen is iPhone SE (375×667); the shell smoke test runs at that size.
- Emoji in the check-in render on iPhone; the Windows screenshot renderer shows them as
  boxes (test-only).
- Notifications: a pure `NotificationPlanner` decides everything (tested); the service just
  applies it. Re-planned whenever blocks, reminders, tasks or settings change.
- Defaults: quiet hours 22:30–07:00; morning nudge 08:00, evening wrap 21:00, Sunday review
  18:00. Anything landing in quiet hours moves to the end of quiet hours.
- The focus-timer chime ignores quiet hours (you started it) and is time-sensitive with the
  bundled `chime.caf`. Both focus-end and break-end alerts are scheduled up front so they
  fire even if the app is never reopened.
- Block alerts only for the next 36 h and never for Rest blocks; repeating nudges get
  priority under iOS's 64-pending limit (we cap at 60).
- Time-sensitive alerts need the entitlement in `ios/Runner/Runner.entitlements` AND the
  "Time Sensitive Notifications" capability on the App ID (CODEMAGIC_SETUP step 2.4).
- Reminders live behind the bell on Today; notification and quiet-hours controls are a
  sheet (tune icon on Reminders) that the Settings screen will reuse in Stage 8.
- Dial: midnight at the top, clockwise; 15-minute snapping with a haptic tick per step.
  Drag on empty ring = new block (opens the block sheet to pick type/task); drag any
  block end = resize; tap a block = edit sheet (type, times ±15, attach task, 5-min alert,
  reminder, start timer, delete). Double-tap or pinch toggles a 6-hour window that starts
  the hour before now. A block crossing midnight (sleep) wraps to the top.
- Unscheduled chips: up to 4 float in the corners around the ring (long-press and drag to
  drop; the drop makes a focus block of the task's estimate). More than 4 → "+N more"
  sheet that can also place a task at the next free slot.
- Capacity counts focus, admin and fixed time (never breaks or rest) against
  Settings → healthy hours (default 8): white under 75 %, lemon 75–100 %, amber over, with
  a gentle line under the dial. Never red.
- Auto-suggest (`PlannerService.suggest`): from the next quarter hour (not before 08:00)
  until 21:00, around fixed/rest/already-started blocks. Low energy: easy wins first,
  ≤25-min blocks, ≤3 h focus. Steady: priority order, ≤50-min blocks, ≤5 h. High: hardest and
  most important first, ≤90-min blocks, ≤6.5 h. Always within the healthy limit; a break
  (5/10/15 min) after every focus block. Preview animates in; "Use this plan" replaces
  only future focus/break/admin blocks.
- Timeline: drag a block to move, drag its bottom edge to resize (blocks under 40 px are
  resized from the editor), tap empty space for a new 1-hour block.
- Energy (Stage 5, `services/energy_service.dart`): low (1–2) → the Now deck shows 3 cards
  (easy wins first; later-planned blocks no longer jump the queue) plus a "N more can wait"
  card, and the timer drops to 25/5. High (4–5) → heaviest, most important first, with a
  small "Hardest first" nudge on the card. The check-in can be redone by tapping the
  "ENERGY n/5" line; a second check-in the same day replaces the first.
- Support message: energy OR mood ≤ 2 on 3 consecutive check-in days (ending today or
  yesterday) → a kind deck card with "See support options" (trusted person, doctor,
  findahelpline.com, local emergency number). "Not today" hides it until tomorrow.
  Nothing is sent anywhere; the link opens in Safari.
- Top 3: star button on Now; up to 3 in order; shown as a slim strip and as TOP n badges;
  ranks lead the deck.
- Progress (`services/progress_service.dart`): goal = 60 % milestones + 40 % linked tasks
  (either alone counts 100 %; achieved = 100 %). Weekly target = its done flag, else the
  share of linked tasks done.
- Week bento: wide "week at a glance" (bars = planned focus/admin/fixed per day against the
  healthy line, dots = tasks done, today lemon), focus-hours and tasks-done tiles, 2-up
  target tiles (100 % turns the tile lemon), hold-and-drag to reorder, a dashed "add" tile
  while under 5, and the next milestone. On Sundays a lemon tile opens the review.
- Sunday review (also from the book icon or the Sunday notification): 1) done this week,
  focus hours, targets hit; 2) carry-over, tap to send something to "someday" instead;
  3) next week's 3–5 targets, pre-suggested from each active goal's next milestone,
  editable; then "Week closed".
- Constellation: 1200×1200 canvas in an InteractiveViewer, auto-fitted on open; goals
  grouped by area (faint labels, hairlines between same-area goals), milestones orbit
  slowly (static with reduced motion). Hold a goal and drag to move it; position is saved.
  Tap → full-screen goal sheet that slides up (why, ring, progress-over-time chart,
  milestone timeline: tap to tick, hold to remove, inline add; weekly targets; tasks).
- Linking: tasks pick a goal and this week's target (narrowed to that goal); targets pick
  a goal and can add tasks for themselves.
- Done (`services/insights_service.dart`): heat map = last 26 weeks, 5 glow levels
  (0, 1–2, 3–4, 5–6, 7+ tasks), today outlined; tap a day → swipeable card stack.
- Area streaks use the same gentle rules per area. "On fire" = longest current streak
  (ties → most days in 30). "Needs attention" = fewest days in 30, only when it is under half
  of the best area's; its button opens a 15-minute light task for today. Never red.
- Sunday summary (Sundays only): most consistent / most neglected area this week, plus one
  concrete suggestion.
- Done stack: Day / Week / Month switch; each period is a fanned card pile you can flick
  through, with tasks finished, focus hours and goals moved in large type.
- Big wins: lemon cards; add one with the trophy button.
- Trends: focus hours per week (12 weeks) and energy (30 days, 3-day rolling average) as
  soft lines. No axes, no "you missed" statistics.
- Brain dump: a small glass button bottom-right above the bar on every main screen (tap =
  capture sheet that stays open for several thoughts; hold = inbox; lemon badge = waiting
  count). Inbox shows notes in two loose columns: "Make a task" or let it go.
- Focus guard: when a focus block ends (and Settings → Focus guard is on) a sheet gives the
  hard-stop break reminder plus optional distraction chips/note, saved on that session.
- Settings (tune icon on Now): theme (Dark / Light / Match iPhone), default rhythm, focus
  guard, healthy hours 4–12, free rest day, all notification controls, reminders, inbox,
  export / import / start fresh, licences.
- Backup: one versioned JSON (`anchor-backup`, v1) of every table plus settings, shared via
  the iOS share sheet. Import validates everything first, then replaces all data in one
  transaction; a bad file changes nothing. "Start fresh" clears the sample data.
- Swapped `file_picker` for Flutter's official `file_selector` (document picker only), so no
  photo-library code ships and the only permission is notifications.
- Widgets/Live Activity are behind TWO switches: `ENABLE_WIDGETS` in codemagic.yaml (adds
  the extension) and `--dart-define=WIDGETS=true` (turns on the Dart side), which Codemagic
  passes only when the extension was actually added. Default off.
- Before touching the project, Codemagic checks that provisioning profiles for both the app
  and `.widgets` contain `group.<bundle id>` (`tool/check_widget_signing.py`); if not, it
  skips widgets and the main app still ships. If the Ruby step fails, the project is reset.
- `tool/add_widget_extension.rb` was run (twice: idempotent) against a copy of the project
  with Ruby 3.3 + xcodeproj 1.28 locally: target, sources, base xcconfig, bundle id
  `$(APP_BUNDLE_ID).widgets`, embed phase placed before "Thin Binary" (avoids the Xcode
  build cycle), App Group added to Runner.entitlements. No explicit framework references
  (autolinked), so no SDK version is pinned.
- The Swift files cannot be compiled on Windows; they were reviewed against the iOS 16.2
  APIs and are first compiled by Codemagic when ENABLE_WIDGETS is turned on.
- Live Activity: `LiveActivitiesAppAttributes` (name required by the plugin); lock screen
  shows phase, task, a self-ticking countdown and progress bar; paused shows the frozen
  time. No remote/push updates.
- Polish (Stage 10): staggered fade-and-lift entrances on Week and Done (≤ 400 ms, off with
  Reduce Motion); system text size is respected up to 130 % (larger sizes are clamped so the
  bold layouts hold); a test renders every tab at iPhone SE size, 160 % text and reduced
  motion in both themes and fails on any overflow (it found and fixed 5).
- App icon: lemon timer ring with a centre dot on near-black (assets/icon_1024.png, all
  sizes in AppIcon.appiconset, no alpha). Launch screen is near-black, so no white flash.
- Not verifiable on Windows: Swift compile, signing, Live Activity, notification sound,
  haptics and real-device performance. These are first proven by the TestFlight build.
