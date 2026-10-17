#!/usr/bin/env python3
"""Catch new English literals at common native UI sinks before they bypass extraction."""
import re
from pathlib import Path
from manage import ROOT, platform, source_root, TOKEN
from source_scan import literals

kind=platform(ROOT)
lang={'android':'kt','ios':'swift','mac':'m'}[kind]
sink=re.compile(r'(?:\bText\(|\.text\s*=|\.stringValue\s*=|\.accessibilityLabel\s*=|\.placeholder(?:String)?\s*=|setTitle\(|setStringValue:|messageText\s*=|informativeText\s*=|NSLocalizedDescriptionKey:|setMessage:)(?:\s*\[NSString stringWithFormat:)?\s*$')
issues=[]
for path in source_root(ROOT).rglob('*.'+lang):
    if 'Vendor' in path.parts:continue
    source=path.read_text()
    for start,end,value in literals(source,lang):
        if not re.search('[A-Za-z]',TOKEN.sub('',value)) or value == 'v%ld' or value.startswith(('https://','http://')):continue
        if sink.search(source[max(0,start-100):start]):
            issues.append(f'{path.relative_to(ROOT)}:{source[:start].count(chr(10))+1}: unlocalized UI literal {value!r}')
if issues:raise SystemExit('\n'.join(issues))
print('No unlocalized literals at the audited UI sinks.')
