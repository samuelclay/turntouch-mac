#!/usr/bin/env python3
"""Test real gesture decoding, persistence and dispatch without controlling devices."""
import pathlib
import subprocess
import tempfile
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='turntouch-button-tests-') as tmp:
    includes = sorted({p.parent for folder in ('Turn Touch Mac', 'Pods') for p in (ROOT / folder).rglob('*.h')})
    common = ['xcrun', 'clang', '-fobjc-arc', '-fmodules', '-Wno-deprecated-declarations', '-Wno-incomplete-implementation', '-framework', 'Cocoa', '-framework', 'IOKit', '-framework', 'CoreBluetooth', '-include', str(ROOT / 'Turn Touch Mac/Supporting Files/Turn Touch Mac-Prefix.pch')]
    for path in includes:
        common += ['-I', str(path)]
    cases = [
        ('gestures', ['Bluetooth/TTGestureDecoder.m'], 'TTGestureDecoderTests.m'),
        ('layouts', ['Models/TTMode.m', 'Models/TTModeMap.m', 'Models/TTModeTwelve.m', 'Models/TTBatchActions.m', 'Models/TTAction.m'], 'TTButtonLayoutTests.m'),
    ]
    for name, sources, test in cases:
        sources = sources + ['TTLocalization.m']
        binary = pathlib.Path(tmp) / f'tt-{name}-{uuid.uuid4().hex}'
        subprocess.run(common + [str(ROOT / 'Turn Touch Mac' / p) for p in sources] + [str(ROOT / 'Turn Touch Mac Tests' / test), '-o', str(binary)], check=True)
        subprocess.run([str(binary), str(ROOT / "Turn Touch Mac/Supporting Files/defaults.plist")], check=True, timeout=30)
