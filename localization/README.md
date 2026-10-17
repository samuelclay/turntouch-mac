# Turn Touch localization

Turn Touch ships English and 20 translations, matching NewsBlur: Spanish, French,
German, Brazilian Portuguese, Italian, Dutch, Polish, Turkish, Russian, Ukrainian,
Arabic, Hebrew, Hindi, Indonesian, Vietnamese, Thai, Japanese, Korean, Simplified
Chinese and Traditional Chinese. The apps never call a translation service.

Automatic uses the device's preferred languages, then English. Portuguese variants
use Brazilian Portuguese; Chinese script and Taiwan/Hong Kong/Macao select the
appropriate Chinese translation. Language is the first settings section and a
first-launch chooser. Android changes immediately, including right-to-left layout,
and integrates with Android 13+ per-app language settings. iOS and macOS save the
selection for the next launch so native nibs and system-provided controls use the
same language. The picker explains this. Each device has its own preference; Turn
Touch has no account-based settings synchronization.

## Updating text

- Android: `tr("Choose your language")`, or `tr("Settings for {0}", remote.name)`.
  Catalog display titles use localized getters; saved action IDs never change.
- iOS: `TTText("Settings for {0}", deviceName)`.
- Mac: `TTText(@"Settings")`, or
  `[NSString stringWithFormat:TTText(@"Settings for %@"), deviceName]`.
- Apple interface files: edit the English file under `Base.lproj`. `ibtool` extracts
  its native localization keys. Do not edit generated `.strings` files.
- iOS Settings.bundle titles, permission explanations, Android's privacy screen,
  and action catalog titles are included.

Translate a complete message. Do not concatenate a translated noun with an English
plural suffix. Use a count label (such as `Scenes: {0}`) or native plural resources.
Never localize Bluetooth values, IDs, storage keys, keyboard keys, URLs, HTTP/JSON
fields, user-entered remote names, or names supplied by a smart-home service.
`extra.json` registers application-owned labels that are looked up at rendering;
it is not permission to translate arbitrary device data.

Run from the repository root (Python 3.10+, no Python packages required):

```sh
python3 localization/manage.py extract
python3 localization/manage.py instructions
OPENAI_API_KEY_FILE=/private/path/to/key python3 localization/manage.py translate --budget 5
python3 localization/manage.py check
python3 localization/manage.py compile
python3 -m unittest discover -s localization
```

`extract` needs Xcode on Apple projects when a Base interface changes; its checked-in
`interfaces.json` permits subsequent validation and compilation on Linux. The source
lexer extracts explicit localization calls and preserves interpolation boundaries.
`source.json` records the source location for each message.

With all three sibling repos checked out, add `--all-repos` to reuse translations
across Android/iOS/Mac. Each repo remains independently buildable and contains its
own translation memory. Shared tooling files are identical in all three repos;
copy changes to the sibling `localization` directories when updating the pipeline.

The translator uses OpenAI Responses structured outputs with GPT-6 Luna, as in
NewsBlur, and accepts `OPENAI_API_KEY` or `OPENAI_API_KEY_FILE`. Credentials are never
stored in the repo or app. `--model`, `--input-price`, and `--output-price` must be
changed together if using a different model. The budget reserves a conservative
upper bound before every request, including retries. Valid batches are saved
immediately; invalid placeholder batches are split and retried. An interrupted run
resumes from saved messages. Machine translation still benefits from native-speaker
review, especially before publishing store copy.

## Automation

The Localization GitHub workflow validates catalogs on pull requests. Main-branch
pushes, a daily schedule, and manual runs translate additions and open a review PR.
Configure the repository's `OPENAI_API_KEY` Actions secret and enable Actions to
create pull requests. The workflow never merges, releases, or submits a store build.
A budget or provider failure is reported instead of replacing translations with
pretend translated English. Apps retain an English fallback for missing keys.

## Store screenshots

`python3 localization/manage.py screenshots` writes the locale/scene manifest.
Capture genuine UI separately for each locale; do not replace text in an English
screenshot. Android's `scripts/capture_store.py --languages es fr` supports localized
capture on the existing phone/tablet. It uses the existing opt-in instrumentation
capture, requires a connected remote, and restores app language and device display
settings afterward. The screenshot test preserves assignments.

On iOS, `run_ios.py --udid <booted-UDID> launch:es` applies a launch-only language
override. `welcome:es` opens the first-launch chooser. Use the existing booted
simulator and `screenshot:<path>`. On macOS, launch the built app with
`-AppleLanguages '(es)' -TT:language es -TT:language:welcomed YES`; these arguments
are temporary and do not rewrite the user's stored preference. Capture settings,
remote actions, action options and connections. Review long German/Russian labels,
CJK glyphs, and Arabic/Hebrew direction. Remote compass geometry must remain fixed.

The manifest is preparation for later store work. A completed build or generated
translation catalog does not mean screenshots were reviewed or a store release was
submitted. No publishing credentials are needed for localization.

Store-copy sources and character limits live in `store-source.json`. Generated
`store/<language>.json` files contain translated titles, descriptions and screenshot
captions. `store-locales.json` maps app language codes to the store's locale IDs;
Google Play uses `iw-IL` for Hebrew and `zh-CN`/`zh-TW` for Chinese. Sources:
[Google Play localization](https://support.google.com/googleplay/android-developer/answer/9844778)
and [App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations/).
The translation script follows [OpenAI structured outputs](https://developers.openai.com/api/docs/guides/structured-outputs).
