#!/usr/bin/env python3
"""Exercise the source-built Hue client without changing real lights."""
import json
import pathlib
import subprocess
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
root = pathlib.Path(__file__).resolve().parents[1]
records = []
class Bridge(BaseHTTPRequestHandler):
    def log_message(self, *args): pass
    def reply(self, payload):
        self.send_response(200); self.send_header('Content-Type', 'application/json'); self.end_headers()
        self.wfile.write(json.dumps(payload).encode())
    def do_GET(self):
        if self.path.endswith('/redirect'):
            self.send_response(302); self.send_header('Location', '/must-not-follow'); self.end_headers(); return
        assert self.path == '/api/fixture-token'
        self.reply({'lights': {'1': {'name': 'Dimmable', 'modelid': 'LWB010', 'state': {'on': True, 'bri': 180}},
                              '2': {'name': 'Color', 'modelid': 'LCT010', 'state': {'on': True, 'bri': 180, 'xy': [.4,.3], 'hue': 2000, 'sat': 200}}},
                    'groups': {'3': {'name': 'Study', 'lights': ['1', '2']}},
                    'scenes': {'evening': {'name': 'Evening', 'lights': ['1', '2']}}})
    def do_PUT(self):
        body=json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        records.append((self.path, body))
        self.reply([{'error': {'type': 201, 'description': 'Scene unavailable'}}] if body.get('scene') == 'error' else [{'success': {self.path: True}}])
with tempfile.TemporaryDirectory(prefix='turntouch-hue-tests-') as tmp:
    binary=pathlib.Path(tmp)/'tests'
    subprocess.run(['xcrun','clang','-fobjc-arc','-fmodules','-framework','Cocoa','-framework','Security',
        '-I',str(root/'Turn Touch Mac/Modes/Hue'),str(root/'Turn Touch Mac/Modes/Hue/TTHueBridge.m'),
        str(root/'Turn Touch Mac Tests/TTHueBridgeTests.m'),'-o',str(binary)],check=True)
    server=ThreadingHTTPServer(('127.0.0.1',0),Bridge)
    threading.Thread(target=server.serve_forever,daemon=True).start()
    try:
        subprocess.run([str(binary),f'127.0.0.1:{server.server_port}'],check=True,timeout=45)
        assert ('/api/fixture-token/lights/1/state', {'on': True, 'bri': 254}) in records
        assert ('/api/fixture-token/groups/3/action', {'on': True, 'bri_inc': -25}) in records
        assert ('/api/fixture-token/groups/3/action', {'scene': 'evening'}) in records
        assert ('/api/fixture-token/scenes/evening/lightstates/2', {'on': False, 'transitiontime': 100}) in records
        assert len(records)==5
        print('PASS: exact Hue light/group/scene/fade requests; unsupported color fields excluded for dimmable bulbs; no retries of physical actions.')
    finally: server.shutdown()
