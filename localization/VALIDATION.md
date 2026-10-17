# Localization validation — 2026-10-16

- 632 extracted messages in this repository; all 21 language catalogs pass missing-key, placeholder, URL, and store-copy length checks.
- Shared translation pipeline: 6 regression tests pass. Static UI-literal audit passes.
- Android: debug app and instrumentation APK build; 20 unit tests pass. A Samsung phone rendered Spanish settings and Arabic controls with east/west geometry preserved. The Spanish store screenshot instrumentation passed and captured all seven scenes.
- iOS: arm64 simulator build succeeds with installed Xcode (deployment target overridden to 26.0 for the local dependency build). Spanish welcome, remote controls, and settings were inspected on the existing iPhone 18 Pro Max simulator; long settings text wraps.
- Mac: arm64 Debug build succeeds with deployment target override 12.0 and local ad-hoc signing. Spanish gesture tabs, settings, and language chooser were inspected in the running native app.
- Both built Apple apps contain all 21 Localizable.strings catalogs, with contents matching the current source catalogs.

Runtime captures from this session are in `/tmp/turntouch-localization-evidence/`.
These are engineering evidence, not a complete store screenshot gallery. Only the
Spanish Android capture sequence was run; all-language phone/tablet/store image
review remains future store work. Machine translations have not had a comprehensive
native-speaker review. Bluetooth/integration actions were not retested across every
language, and simulator checks do not prove physical iOS Bluetooth behavior.

No store submissions or releases were performed. The GitHub translation workflow
needs the repository's `OPENAI_API_KEY` Actions secret and a merge to the default
branch before scheduled translation runs can operate. PR catalog validation does
not require credentials.

Fresh PR galleries cover the welcome chooser, top-of-settings Language entry,
settings chooser, and Spanish, Arabic, and Japanese examples. Screenshots are
uploaded to the corresponding GitHub PR rather than bundled into the app.
