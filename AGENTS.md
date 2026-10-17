# Localization

All new user-visible app text must use the localization helper described in
[localization/README.md](localization/README.md). Keep protocol IDs, stored settings
values, shortcut keys and user content literal. Run extract, translate, check and
compile when changing UI copy; include catalogs and translation memory with the
change. For Apple Base interfaces, extract on macOS with Xcode. Review long labels
and right-to-left languages. Keep remote compass directions fixed.

Do not submit store releases as part of a localization update.
