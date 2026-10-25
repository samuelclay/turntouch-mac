# Mac release and update verification

Use this procedure for every Mac release and production app installation. It does
not authorize a release by itself. The reusable verification script is
[`scripts/verify_mac_update.py`](../scripts/verify_mac_update.py).

## Why this is required

The installed 2.1 app was once replaced during local testing with an ad-hoc signed
build. It still displayed version 2.1, but Sparkle rejected the correctly signed
2.2 update: the old app's designated requirement was a build-specific code hash,
not the production Developer ID requirement. The public 2.1 and 2.2 apps passed
the same Sparkle signature comparison. A matching version label is not proof
that the installed app is the published release.

Keep development builds under their build paths. Never copy an ad-hoc signed
build over `/Applications/Turn Touch Mac.app`, and never disable signature
verification to make an update work.

## Prepare and verify the release

1. Record the source commit, marketing version, and increasing bundle build number.
   Archive the Release configuration for both Apple Silicon and Intel. Distribute
   with Developer ID, submit for notarization, wait for acceptance, and export the
   notarized app. The production team is `6W5HRS3393` and bundle identifier is
   `com.turntouch.mac-remote`. Do not modify or re-sign the exported app ad hoc.
2. Obtain the previous public ZIP from its versioned enclosure URL in
   [the live appcast](https://www.turntouch.com/app/appcast/). Preserve it before
   changing the feed. Use the actual public artifact, not a local Xcode build.
3. Package the candidate app with `ditto -ck --keepParent --norsrc --noextattr --noqtn`.
   The web repo's `make cocoa VERSION=...` uses these flags and packages this
   checkout's `Turn Touch Mac.app`. Preserve the `.app` name inside the ZIP;
   reject `._` AppleDouble entries or `__MACOSX` metadata. Do not alter the signed
   bundle to repair packaging: repackage the original notarized export.
4. Extract the previous public ZIP and the final candidate ZIP into separate fresh
   directories, then run the check from this repo:

   ```sh
   verification_root="$(mktemp -d /tmp/turntouch-release-check.XXXXXX)"
   ditto -xk '/path/to/previous-public.zip' "$verification_root/previous"
   ditto -xk '/path/to/candidate.zip' "$verification_root/candidate"
   python3 scripts/verify_mac_update.py \
     "$verification_root/previous/Turn Touch Mac.app" \
     "$verification_root/candidate/Turn Touch Mac.app"
   ```

   Requires macOS, Xcode command-line tools, Python 3, and this checkout's Sparkle
   headers. The checker loads the previous app's embedded Sparkle framework. It
   verifies both app signatures before loading code, validates the candidate's
   stapled notarization ticket and Gatekeeper acceptance, and checks increasing
   build number, bundle ID, and Sparkle signing compatibility. **Any nonzero exit
   blocks publication.** If a future Sparkle upgrade changes the verifier API,
   adapt the check to that release rather than removing it.
5. Record the ZIP's SHA-256 and byte count. Ensure the appcast enclosure URL,
   length, `sparkle:version` (bundle build number), `sparkle:shortVersionString`,
   and minimum system version match the verified candidate. Retain the previous
   release for rollback and upgrade testing.

## Verify deployment and installation

After an authorized deployment, fetch the live appcast and its exact versioned
ZIP URL. Compare the public ZIP's SHA-256 and length with the verified candidate,
extract it into a fresh directory, and rerun the script against the previous
public app. Check that the stable appcast and `/download` endpoints are not served
with immutable or long-lived caching; versioned ZIPs may be cached indefinitely.

On a test installation of the previous **public, signed** app, use **Check for
Updates**, download, install, and relaunch. Verify the running process's bundle
path, new version/build, and signing identity. Do not claim this UI flow passed
based only on the command-line check. If the desktop cannot be controlled, record
the UI verification as incomplete and report that limitation.

Record the source commit, artifact hash, notarization result, downloaded-artifact
verification, and interactive upgrade result in `store/release-status.json` or
linked release evidence. Keep published, installed, and UI-tested states distinct.

## Recover a development installation

If Sparkle reports a signing mismatch, inspect the installed bundle with
`codesign -dv --verbose=4 '/Applications/Turn Touch Mac.app'` and inspect Sparkle's
log. `Signature=adhoc` and no team identifier indicate a local test build.

Verify the official current release using the procedure above. Quit the running
app, preserve a backup of its bundle, replace it with the verified signed and
notarized release, and relaunch. Leave preferences, remote assignments, and
Keychain entries intact. Confirm the running path and installed version/signature.
The current app can then trust subsequent updates signed with the production
identity.
