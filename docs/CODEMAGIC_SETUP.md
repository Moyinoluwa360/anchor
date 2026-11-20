# Codemagic + TestFlight setup (one time, no Mac needed)

Everything here is done in a web browser. Do the steps in order. Where a step
says "tell Claude", paste the result back so the next stage can use it.

Bundle identifier used everywhere: **`com.anchorapp.anchor`**. To use a
different one, change it in `ios/Flutter/AppConfig.xcconfig`,
`lib/app_config.dart`, `codemagic.yaml` (`BUNDLE_ID` and
`ios_signing.bundle_identifier`) and the three `RunnerTests` lines in
`ios/Runner.xcodeproj/project.pbxproj`. Every build runs
`tool/check_bundle_id.sh`, which stops the build if they don't match.

## 1. Apple Developer account
1. You need the paid Apple Developer Program (developer.apple.com/programs).

## 2. Register the App ID
1. Go to developer.apple.com → Account → Certificates, Identifiers & Profiles → **Identifiers** → **+**.
2. Choose **App IDs** → **App** → Continue.
3. Description: `Anchor`. Bundle ID: **Explicit**, `com.anchorapp.anchor`.
4. Capabilities: tick **Time Sensitive Notifications** (lets the timer alarm
   break through Focus modes). **Required**: the app's entitlements file asks for
   it, and signing fails without it. Leave everything else off for now. Stage 9
   adds App Groups, with its own steps below.
5. Continue → Register.

## 3. Create the app in App Store Connect
1. appstoreconnect.apple.com → **Apps** → **+** → **New App**.
2. Platform iOS, Name `Anchor` (or any free name), language, Bundle ID
   `com.anchorapp.anchor`, SKU `anchor-ios`, Full Access.
3. Open the app → **App Information** → copy the **Apple ID** (a number like
   `6740000000`). Put it in `codemagic.yaml` as `APP_STORE_APPLE_ID`, or tell Claude.

## 4. App Store Connect API key (lets Codemagic sign and upload)
1. App Store Connect → **Users and Access** → **Integrations** → **App Store Connect API** → **Team Keys** → **+**.
2. Name `Codemagic`, Access **App Manager** → Generate.
3. Download the `.p8` file (you can only download it once) and note the
   **Issuer ID** and **Key ID** shown on the page.
4. Never put this file in the repository.

## 5. Codemagic
1. Push this folder to a **private** GitHub repository (Claude can do this with you).
2. Sign in at codemagic.io with GitHub → **Add application** → pick the repo →
   project type **Flutter App (via codemagic.yaml)**.
3. Codemagic → **Team settings** (or Personal account) → **Integrations** →
   **Developer Portal** → **Manage keys** → **Add key**:
   - Name: **`Anchor ASC key`** (must match `integrations.app_store_connect` in `codemagic.yaml`)
   - Issuer ID, Key ID, and upload the `.p8`.
4. Open the app in Codemagic → **Start new build** → workflow
   **Anchor iOS → TestFlight** → branch `main`.
   Codemagic creates the distribution certificate and provisioning profile
   automatically (`ios_signing` in `codemagic.yaml`).

## 6. TestFlight
1. After the first successful build, App Store Connect → your app → **TestFlight**.
2. Under **Internal Testing** create a group, add yourself.
3. Answer the export-compliance question if asked (the app declares it uses no
   non-exempt encryption, so it usually won't ask).
4. Install **TestFlight** on the iPhone and accept the invite.

From then on: `git push` → new build on the phone in about 20–30 minutes.

## 7. Widgets and Live Activity (optional; do this after the app is on TestFlight)

The home screen widgets (Now card, Top 3, Weekly targets) and the lock-screen
timer live in a separate "widget extension". Codemagic only adds it when the
Apple side below is ready; otherwise it quietly builds the app without it.

**A. Create the App Group**
1. developer.apple.com → Certificates, Identifiers & Profiles → **Identifiers**.
2. Top-right filter → **App Groups** → **+** → App Groups → Continue.
3. Description `Anchor`, Identifier **`group.com.anchorapp.anchor`** → Continue → Register.

**B. Give the app the App Group**
1. Identifiers → filter **App IDs** → click **Anchor** (`com.anchorapp.anchor`).
2. Tick **App Groups** → **Configure** → select `group.com.anchorapp.anchor` → Continue → **Save**
   (confirm the warning: existing profiles become invalid, which is expected).

**C. Register the widget extension**
1. Identifiers → **+** → App IDs → App → Continue.
2. Description `Anchor Widgets`, Bundle ID Explicit **`com.anchorapp.anchor.widgets`**.
3. Tick **App Groups** → Configure → select `group.com.anchorapp.anchor`. Nothing else
   (Live Activities need no extra capability; the timer updates come from the app).
4. Continue → Register.

**D. Clear the old profiles**
1. **Profiles** → delete the App Store profile(s) for `com.anchorapp.anchor` (they were
   made before the App Group existed). Codemagic creates fresh ones on the next build.

**E. Turn it on**
1. In `codemagic.yaml` set `ENABLE_WIDGETS: "true"` (or tell Claude to), commit, push.
2. In the build log, the "Widget extension" step says either
   - `Widget signing ready.` then `Added AnchorWidgets ...` → widgets are in this build, or
   - `Skipping widgets this build.` → a step above is missing; the app still ships.
3. If the build fails while compiling the widgets, set `ENABLE_WIDGETS: "false"` to keep
   shipping, and send Claude the failing part of the log.

**F. On the iPhone**
1. Home screen → long-press → **+** → search **Anchor** → pick Now, Top 3 or Weekly targets.
2. Start a focus timer and lock the phone: the timer shows on the lock screen. If not:
   iPhone Settings → Anchor → **Live Activities** on.
