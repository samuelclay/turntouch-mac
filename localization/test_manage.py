import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import manage

class LocalizationTests(unittest.TestCase):
    def test_extracts_display_calls_without_protocol_literals(self):
        text='let data = ["title": TTText("A \\"quoted\\" title"), "path": "TT:mode"]'
        self.assertEqual(list(manage.call_messages(text,'swift')),['A "quoted" title'])
        kotlin='Text(tr("Choose {0}", device.name)); config["title"] = "Hue"'
        self.assertEqual(list(manage.call_messages(kotlin,'kt')),['Choose {0}'])

    def test_literal_percent_before_prose_is_not_a_format_directive(self):
        self.assertEqual(manage.TOKEN.findall('Battery: {0}% battery'),['{0}'])
        self.assertEqual(manage.TOKEN.findall('Batterie: {0}% de charge'),['{0}'])
        self.assertEqual(manage.TOKEN.findall('%ld devices, %@, %.1f%%'),['%ld','%@','%.1f','%%'])

    def test_bare_url_schemes_allow_adjacent_grammatical_suffixes(self):
        self.assertTrue(manage.placeholders_match('Enter an http:// or https:// URL','Eine http://- oder https://-Adresse eingeben'))
        self.assertFalse(manage.placeholders_match('Visit https://turntouch.com','Visit https://example.com'))

    def test_validation_rejects_dropped_and_type_changed_format_arguments(self):
        memory={code:{'%ld devices':'%d devices'} for code in manage.LANGUAGES if code!='en'}
        self.assertEqual(len(manage.validate({'%ld devices':[]},memory)),20)

    def test_shortcut_key_examples_are_excluded_from_translation(self):
        for key in ['hWm-ST-6Jx.title','kBl-wm-9eG.title']:
            self.assertFalse(manage.interface_text_is_translatable('TTModeCustomKeyboardOptions.xib',key))
        self.assertTrue(manage.interface_text_is_translatable('TTModeCustomKeyboardOptions.xib','ekQ-MT-yKk.title'))

    def test_compiler_replaces_utf16_apple_strings_safely(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'Root.strings';p.write_text('"Name" = "Name";',encoding='utf-16')
            manage.strings_file(p,{'Name':'Nom'})
            self.assertIn('"Name" = "Nom";',p.read_text())

if __name__=='__main__':unittest.main()
