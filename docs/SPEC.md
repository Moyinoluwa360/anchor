# Anchor — product spec (source of truth)

Saved verbatim from the owner's build prompt on 2026-11-20. Progress is tracked in
[BUILD_PLAN.md](BUILD_PLAN.md).

---

## Role and goal

You are a senior Flutter engineer and product designer. Build a Flutter app (Dart, latest stable Flutter) called **Anchor**, targeting iOS. It is a personal productivity and time-management app for one user who runs a startup, learns cloud engineering, and does side gigs. The user gets overwhelmed and foggy when everything feels urgent, so the app must reduce overwhelm, make starting effortless, and celebrate progress instead of punishing missed tasks.

**Development environment:** the user develops on Windows and has no Mac and no Xcode. The app is built in the cloud with Codemagic, which signs the build and uploads it to TestFlight through App Store Connect. Everything you write must work under that setup: never tell the user to open Xcode, and never depend on a local Mac. Where native iOS files are needed, create them as plain source files in the repository so Codemagic can build them.

## Design principles

1. **One thing at a time.** The home screen answers a single question: what is the one thing I do right now? The deck can be swiped, but the centre card is always the one to focus on.
2. **Tiny first steps.** Every task can be shrunk into a 5-minute starter step to beat the fog at the starting line.
3. **Protect work and rest.** Focus blocks have hard stops, and breaks are scheduled, not optional.
4. **Adapt to energy.** A quick morning check-in changes how heavy the day plan is.
5. **Celebrate, do not shame.** No red overdue counters and no broken-streak guilt. Show what was done.

## Visual design and interaction (clean, bold, not a normal list app)

The reference for taste is sites like Linear: clean, confident, precise. Do not copy Linear's layout. The goal is something distinctive that does not look like a standard to-do list.

**Colour palette**

- Background: true near-black (#0A0A0A) with a slightly lifted surface colour (#141414) for cards and a hairline border (#262626).
- Text: pure white for primary, soft grey (#8A8A8A) for secondary.
- One electric accent: lemon green (#D4FF3A). Use it sparingly and on purpose: the active task, progress fills, the primary button, the timer ring, and completion moments. Text on the accent colour is near-black.
- A full light theme that inverts the idea: off-white background, near-black text, and the lemon green kept as a highlight with dark text on it.
- Life Areas are told apart by icon and a small label, with subtle tints of grey and green, not a rainbow, so the screen stays calm and strictly black, white, and lemon.

**Typography**

- Use a sharp modern grotesk through google_fonts: Space Grotesk or Sora for headings and big numbers, Inter for body text. Add a monospace like JetBrains Mono for timers, times, and small data labels.
- Big, confident type: oversized countdown numbers, tight letter spacing on headings, generous whitespace, and a strict type scale used everywhere.

**Layout and interaction: break the vertical list**

- Give every screen its own distinctive layout. Do not use plain vertical lists, and do not make every screen a sideways swipe either: Now is a card deck, Today is a circular dial, Week is a bento board, Goals is a constellation, and Done is a heat map with a stack of wins. Use PageView, CustomPainter, InteractiveViewer, and custom gestures where needed.
- Cards that can be swiped, flipped, snapped, and dragged. Completed items fly off with a snap and a short haptic.
- Fluid motion everywhere: shared-element transitions between screens, spring physics, staggered entrances, and no abrupt cuts. Keep every animation under about 400 ms and honour the reduced-motion setting.
- Navigation uses go_router with a shell route and a custom liquid glass bottom bar instead of the standard tab bar. It is a rounded glass capsule that sits low on the screen, close to the bottom edge, with spacing like the WhatsApp bottom bar: a small margin on the left and right (about 16 to 20 points) and only a small gap above the home indicator (about 8 to 12 points), never floating high up in the screen. It stays slim, around 60 to 64 points tall. The capsule uses a real frosted blur (BackdropFilter with ImageFilter.blur), a translucent white tint at about 8 to 12 percent opacity, a thin bright hairline border with a faint top highlight, and a soft shadow, so the content behind it shows through. It holds five icons (Now, Today, Week, Goals, Done). The active tab is marked by a smaller glass bubble that slides between tabs on a spring and stretches slightly in the direction of travel, like a drop of liquid, while the active icon turns lemon green and its label fades in beneath it. Tapping gives a soft haptic. The bar shrinks and fades slightly while the user scrolls down and returns when they scroll up. It must look good over both the dark and the light theme.
- Subtle details: a faint grain or dot grid on the background, hairline dividers, rounded corners around 20 to 28, and soft haptics on every meaningful action.
- Empty states and copy should be short, warm, and a bit playful, never preachy.

## Data model

- **Goal**: title, life area, why it matters (short text), target date, status, progress (computed from linked milestones and tasks). Supports long-term goals (3 to 12 months).
- **Milestone**: belongs to a goal, title, due date, done flag.
- **WeeklyTarget**: belongs to a goal, week start date, title, done flag.
- **Task**: title, life area, optional goal link, optional weekly target link, estimated minutes, optional tiny first step text, scheduled date, optional time block, status, completedAt.
- **TimeBlock**: start time, end time, optional task link, label, type (focus, break, admin, rest, fixed commitment).
- **FocusSession**: task link, planned duration, actual duration, start, end, completed flag.
- **EnergyCheckIn**: date, energy level 1 to 5, mood 1 to 5, optional note.
- **Reminder**: title, date and time, repeat rule, linked task optional.

## Screens and features

### 1. Now (home)

- **Deck of cards, not a list.** The screen is a full-height horizontal card deck (PageView with a peeking next card). The centre card is the current task: a huge title, its tiny first step, and an oversized monospace countdown. Swipe sideways to flip through the rest of today's tasks. Swipe a card up to complete it (it flies off with a snap and haptic) and swipe down to snooze it.
- A big lemon green **Start** button anchored at the bottom begins the focus timer. While a timer runs, the card turns into a full-screen timer view: a giant lemon green ring drawn with CustomPainter that drains smoothly, with the remaining time in large type.
- A slim "Up next" rail of the next two blocks peeks in from the right edge of the screen.
- A **Stuck?** button that shrinks the task: it offers to split it into a 5-minute starter step, swap it for an easier task, or take a 5-minute reset break.
- Shows the energy check-in prompt as a first card in the deck if not done today.

### 2. Today (24-hour planner)

- **Circular 24-hour dial.** The day is a large ring drawn with CustomPainter, like a clock face showing all 24 hours, with a lemon green "now" hand that moves in real time. Time blocks are thick arcs on the ring. The user drags along the ring to create an arc, and drags the arc ends to resize it. Arcs snap to 15-minute steps.
- The centre of the dial shows the current block, its remaining time in large monospace type, and a small Start button.
- A pinch or double tap zooms the dial between the full 24 hours and a focused 6-hour window for fine editing.
- Unscheduled tasks float as small chips around the outside of the ring and can be dragged onto it to schedule them.
- Tap an arc to edit, attach a task, set a reminder, or start a timer.
- A daily capacity ring inside the dial shows planned hours against a healthy limit and turns from white to lemon green to amber warning as the day fills, warning gently when overpacked.
- Option to auto-suggest a plan: given the energy level, estimated minutes, and priorities, animate a proposed day layout with breaks onto the ring for the user to accept or edit.
- A toggle switches to a flat timeline view of the same blocks for precise editing.

### 3. Week

- **Bento board.** The Week screen is a grid of mixed-size rounded tiles, like a bento box, not a list. One wide tile shows the week at a glance: seven small vertical bars for each day's load, with today in lemon green.
- Each **Weekly target** (3 to 5 outcomes, each linked to a goal) is its own tile with a large percentage, a thick progress bar, and the goal's icon. Tiles can be long-pressed and dragged to reorder.
- Extra tiles: focus hours so far this week, tasks done this week, and the next milestone coming up.
- A Sunday review flow told as a short sequence of full-screen story-style cards: what got done, what to carry over, then pick next week's targets.

### 4. Goals

- **Goal constellation.** Goals appear as nodes on a pannable, zoomable canvas (InteractiveViewer), grouped by life area, with milestones orbiting each goal as small dots. Each goal node has a lemon green progress ring that fills as milestones and tasks are completed. Nodes can be dragged and the layout is remembered.
- Tap a goal to open its detail as a full-screen sheet: why it matters, milestones, linked weekly targets, linked tasks, and a simple timeline of progress.
- A toggle switches to a compact horizontal carousel view of the same goals.
- Pre-seed the app with these example goals the user can edit: grow the startup (hundreds of daily users to a larger base), learn cloud engineering, earn short-term income from clipping gigs, and ship the AI outfit search system.

### 5. Done

- **Heat map.** A contribution-style grid of the last several months, where each day is a small rounded square that glows brighter lemon green the more the user got done that day. Tap a day to open a card stack of what was completed.
- A **gentle streak** counter: consecutive days with at least one task done. It floats on the left side of the screen as a small liquid glass bubble, visible as soon as the app opens and on every main screen, with nothing else in the top corner: a flame icon with the number in lemon green, for example "12", on the same frosted blur, translucent tint, and hairline border as the bottom bar. It rests near the top of the left edge, can be dragged up and down along the edge and remembers its spot, and slides slightly off-screen while the user scrolls down and returns when they scroll up. It counts up briefly when the app opens, and tapping it opens the Done screen. The Done screen can show the same number larger beside the best streak ever. A missed day pauses the streak quietly instead of resetting it to zero, and the app offers one free "rest day" per week that never breaks it. Never show a broken-streak message or a red state. Also show the user's best streak ever.
- **Streaks by life area.** A panel showing a separate streak for each life area (Startup, Cloud Learning, Side Gigs, Health, Personal), so the user can see what they work on consistently and what they neglect. Each area shows its current streak, its best streak ever, and a small bar of how many days it got attention in the last 30 days. The strongest area is highlighted in lemon green with a label like "On fire". The most neglected area is flagged gently as "Needs attention" in white or soft grey, never red, with a one-tap button to schedule a small task for it today. Add a weekly summary card on Sundays: your most consistent area, your most neglected area, and one suggestion for next week.
- A **Done stack**: completed tasks pile up as a growing stack of cards the user can scrub through, grouped by day, week, and month, with totals like tasks finished, focus hours, and goals advanced shown in large type.
- A highlights card for big wins (for example, shipped an app to the App Store), shown in lemon green.
- Gentle trends only: focus hours per week and energy over time, drawn as simple smooth lines. Never show guilt-based statistics.

## Timers and notifications

- Focus timer with presets (25/5, 50/10, 90/20) and a custom option, shown on the lock screen as a Live Activity (the user's phone has no Dynamic Island, so design for the lock screen and the compact banner only).
- When a timer ends, play a clear beep or chime sound (use a bundled short audio file) with a strong haptic, even when the app is in the background, via flutter_local_notifications with scheduled notifications, a custom sound, and the time-sensitive interruption level.
- Local notifications for: upcoming time blocks (5 minutes before), reminders, a morning check-in nudge, an evening wrap-up prompt, and the Sunday review.
- Quiet hours setting so notifications respect sleep.
- Request notification permission with a friendly explanation screen.

## Energy check-in and adaptation

- A 10-second morning check-in: energy (1 to 5) and mood (1 to 5) using large tappable emoji-style buttons.
- Low energy: the app limits the day to a lighter plan, suggests shorter focus blocks, and prioritises easy wins.
- High energy: the app suggests putting the hardest, most important task first.
- If energy or mood stays at 1 or 2 for several days in a row, show a kind, non-alarming message suggesting the user talk to someone they trust or a health professional, with a button to open a short list of support resources.

## Extra features

- **Daily top 3**: choose up to three must-do tasks for the day.
- **Brain dump**: a quick-capture button available anywhere to type a thought, to be sorted later.
- **Focus guard**: a gentle reminder at the end of a focus block, and an optional prompt to log distractions.
- **Home screen widgets**: Now card, today's top 3, and weekly target progress (home_widget package, with the widget extension files added as plain source files).
- Everything stays on the phone: no accounts, no server, no cloud sync.
- Export data as JSON from settings.

## Technical requirements

- Flutter and Dart with Riverpod for state management, Drift (SQLite) for all local storage, flutter_local_notifications with timezone for scheduling, audioplayers for the alarm sound, home_widget for widgets, and live_activities for the lock screen timer.
- Clean folder structure: models, data (Drift database and repositories), providers, screens, widgets, services (NotificationService, TimerService, PlannerService), theme, assets.
- Accessibility: respect system text scaling, Semantics labels for VoiceOver, sufficient contrast, and reduced motion support.
- Include sample seed data so the app looks full on first launch.
- Write unit tests for the planner logic and the timer logic with flutter_test.

## Storage: local only

All data lives on the device in a local Drift (SQLite) database. Do not use Firebase, Supabase, or any backend or network service. There are no logins and no analytics. Notifications are all local. Add a Settings option to export all data as JSON and import it back, so a phone change or backup is possible. Request no permissions beyond notifications.

## Build order: build everything, stage by stage

Build the complete app, every feature in this document. Work through the stages below strictly in order. Finish and verify one stage before starting the next, and at the end of each stage say what is done and what is next.

1. **Foundation.** Project setup, folder structure, theme (colours, typography, life area colours and icons), Drift database and tables, seed data, and the five-tab navigation shell. Also create the codemagic.yaml described in the Codemagic section so the app builds to TestFlight from day one.
2. **Now screen and focus timer.** The swipeable card deck, Start button, Stuck? flow, task shrinking, swipe up to complete and down to snooze, and the focus timer with the draining lemon green ring, presets, haptics, and the end-of-timer alarm sound.
3. **Notifications and reminders.** Permission flow, block-start alerts, reminders with repeat rules, morning check-in nudge, evening wrap-up, quiet hours, and time-sensitive timer alerts.
4. **Today planner.** The circular 24-hour dial drawn with CustomPainter, drag to create and resize arcs, floating task chips, the zoom, arc editing, the capacity ring, the auto-suggest day plan, and the flat timeline toggle.
5. **Energy check-in and adaptation.** Daily check-in, plan adjustment by energy, daily top 3, and the gentle support message for several low days in a row.
6. **Week and Goals.** The bento board with weekly target tiles and the daily load bars, the Sunday review story cards, then the goal constellation canvas with milestones and progress rings, the carousel toggle, and the linking between goals, targets, and tasks.
7. **Done list and insights.** The heat map, the gentle streak and the streaks by life area with the Needs attention flag and Sunday summary card, the Done stack by day, week, and month, highlights for big wins, and gentle trends.
8. **Extras.** Brain dump quick capture, focus guard, JSON export and import, and settings.
9. **Widgets and Live Activities.** Home screen widgets and the lock screen timer Live Activity. These need native Swift widget extension files, written as plain source files and wired into the Runner project without Xcode, as described in the Codemagic section. Because this is the riskiest stage, make sure the app still builds and ships without it, and add it last.
10. **Polish and testing.** Animations, haptics, accessibility, dark and light mode check, unit tests for the planner and timer, and a final pass so the whole app builds cleanly in Codemagic and runs end to end on a real iPhone through TestFlight.

After each stage, make sure the project passes flutter analyze and builds, and tell the user which commands to run on Windows and what to push so Codemagic produces a new TestFlight build.

## Codemagic and TestFlight setup (Windows, no Xcode)

The user has no Mac. Every build runs on Codemagic's cloud Macs and goes to TestFlight. Do the following.

- Create a `codemagic.yaml` with an iOS workflow on a macOS instance: install dependencies with `flutter pub get`, run `flutter analyze` and `flutter test`, build with `flutter build ipa --release`, sign automatically using the App Store Connect API key integration, and publish to TestFlight. Auto-increment the build number from the latest TestFlight build so uploads are never rejected for a duplicate number.
- Use environment variables or Codemagic integrations for the App Store Connect key, never commit secrets. Set the bundle identifier in one place and keep it consistent everywhere, including extensions.
- In `Info.plist`, add the keys needed for notifications and background audio, and set the minimum iOS version to 16.2 so Live Activities work. Add `NSSupportsLiveActivities` as true.
- Add the custom alarm sound file to the Runner bundle through the project file, and make sure it is under 30 seconds and in a supported format (caf or aiff for notifications).
- For the widget extension and Live Activity, write the Swift files, the extension `Info.plist`, entitlements, and an App Group shared between the app and the extension. Since Xcode cannot be used, add the extension target to `ios/Runner.xcodeproj/project.pbxproj` with a small Ruby script using the `xcodeproj` gem that runs in the Codemagic pre-build step, and also create the extra bundle identifier and provisioning profile through Codemagic's automatic signing. Document each manual step the user must do in the Apple Developer portal (App ID, App Group, capabilities) in plain numbered instructions.
- If the widget extension step fails, the workflow must still be able to build the main app. Put the extension script behind a flag so the user can turn it off and keep shipping.

## Quality bar

Deliver the full feature set, not a reduced version. Keep code clean and maintainable, keep every screen consistent with the design principles and the black, white, and lemon green visual direction above, and do not skip a feature to save time. If something is ambiguous, pick the sensible default and note it at the end of the stage.
