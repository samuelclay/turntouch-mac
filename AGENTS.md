# Localization

All new user-visible app text must use the localization helper described in
[localization/README.md](localization/README.md). Keep protocol IDs, stored settings
values, shortcut keys and user content literal. Run extract, translate, check and
compile when changing UI copy; include catalogs and translation memory with the
change. For Apple Base interfaces, extract on macOS with Xcode. Review long labels
and right-to-left languages. Keep remote compass directions fixed.

Do not submit store releases as part of a localization update.

# Mac releases and local installation

Before preparing or publishing a Mac release, or replacing the production app in
`/Applications`, read and follow [docs/mac-release.md](docs/mac-release.md).
Run `python3 scripts/verify_mac_update.py PREVIOUS_APP CANDIDATE_APP` on unmodified
apps extracted from the previous public ZIP and the candidate ZIP. A failed
signature, notarization, version, or identity check blocks publication. Recheck
the downloaded public artifact after deployment and record the result separately
from the interactive update/install/relaunch result.

Never replace the installed production app with an ad-hoc signed development
build. Keep local builds at their build paths. Recover an existing development
installation using the verified signed, notarized release while preserving
preferences and Keychain items; do not bypass Sparkle's signature checks.
