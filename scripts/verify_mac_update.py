#!/usr/bin/env python3
"""Verify Mac update signing, notarization, and compatibility with the previous app.

Pass .app bundles extracted from the previous public ZIP and the candidate ZIP.
Requires macOS, Xcode tools, and this checkout's Sparkle headers. A nonzero exit
blocks release. This does not test Sparkle's download/install/relaunch UI.
"""
import argparse
import pathlib
import subprocess
import tempfile


SOURCE = r'''
#import <Foundation/Foundation.h>
#import "SUCodeSigningVerifier.h"
#import "SUStandardVersionComparator.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 3) return 2;
        NSURL *oldURL = [NSURL fileURLWithPath:@(argv[1])];
        NSURL *newURL = [NSURL fileURLWithPath:@(argv[2])];
        NSBundle *old = [NSBundle bundleWithURL:oldURL];
        NSBundle *next = [NSBundle bundleWithURL:newURL];
        NSString *oldVersion = [old objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *newVersion = [next objectForInfoDictionaryKey:@"CFBundleVersion"];
        if (!oldVersion.length || !newVersion.length) return 2;
        BOOL sameID = [old.bundleIdentifier isEqualToString:@"com.turntouch.mac-remote"] &&
            [old.bundleIdentifier isEqualToString:next.bundleIdentifier];
        BOOL newer = [[SUStandardVersionComparator defaultComparator]
            compareVersion:oldVersion toVersion:newVersion] == NSOrderedAscending;
        NSError *error = nil;
        BOOL trusted = [SUCodeSigningVerifier codeSignatureAtBundleURL:oldURL
            matchesSignatureAtBundleURL:newURL error:&error];
        printf("Build %s -> %s: newer=%s, bundle ID=%s, Sparkle signature=%s\n",
            oldVersion.UTF8String, newVersion.UTF8String, newer ? "PASS" : "FAIL",
            sameID ? "PASS" : "FAIL", trusted ? "PASS" : "FAIL");
        if (error) fprintf(stderr, "%s\n", error.localizedDescription.UTF8String);
        return sameID && newer && trusted ? 0 : 1;
    }
}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('previous_app', type=pathlib.Path)
    parser.add_argument('update_app', type=pathlib.Path)
    args = parser.parse_args()
    previous = args.previous_app.resolve(strict=True)
    update = args.update_app.resolve(strict=True)
    frameworks = previous / 'Contents/Frameworks'
    if not (frameworks / 'Sparkle.framework/Sparkle').is_file():
        parser.error('The previous app must contain Sparkle.framework')
    headers = pathlib.Path(__file__).resolve().parents[1] / 'Pods/Sparkle/Sparkle.framework/Headers'
    # Verify the old bundle before loading its framework into the checker.
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(previous)], check=True)
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(update)], check=True)
    subprocess.run(['xcrun', 'stapler', 'validate', str(update)], check=True)
    subprocess.run(['spctl', '--assess', '--type', 'execute', '--verbose=2', str(update)], check=True)
    with tempfile.TemporaryDirectory(prefix='turntouch-update-check-') as directory:
        source = pathlib.Path(directory) / 'verify.m'
        binary = pathlib.Path(directory) / 'verify'
        source.write_text(SOURCE)
        subprocess.run(['xcrun', 'clang', '-fobjc-arc', '-framework', 'Foundation',
                        '-I', str(headers), '-F', str(frameworks), '-framework', 'Sparkle',
                        '-Xlinker', '-rpath', '-Xlinker', str(frameworks),
                        str(source), '-o', str(binary)], check=True)
        # Load the old app's actual framework, not the checkout's newer version.
        return subprocess.run([str(binary), str(previous), str(update)]).returncode


if __name__ == '__main__':
    raise SystemExit(main())
