#!/usr/bin/env python3
"""Test the production Hue v2 client without changing any physical devices."""
import collections
import http.server
import json
import pathlib
import subprocess
import tempfile
import threading

requests = collections.Counter()
class Fixture(http.server.BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_PUT(self):
        requests[self.path] += 1
        assert self.headers.get('hue-application-key') == 'fixture-only'
        body = self.rfile.read(int(self.headers.get('Content-Length', '0')))
        assert json.loads(body) == {'on': {'on': True}}
        status, response = 200, {'data': [{'rid': 'fixture-light'}], 'errors': []}
        if self.path in ('/api-error', '/partial-error'):
            response['errors'] = [{'description': 'Fixture: unsupported action'}]
            if self.path == '/api-error':
                response['data'] = []
        elif self.path == '/malformed':
            response = []
        elif self.path == '/unauthorized':
            status = 403
        elif self.path == '/redirect':
            status = 307
        self.send_response(status)
        if status == 307:
            self.send_header('Location', f'http://127.0.0.1:{self.server.server_port}/redirect-target')
        data = json.dumps(response).encode()
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

root = pathlib.Path(__file__).resolve().parents[1]
api = root / 'Turn Touch Mac/Modes/Hue/API'
server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Fixture)
threading.Thread(target=server.serve_forever, daemon=True).start()
try:
    with tempfile.TemporaryDirectory(prefix='turntouch-hue-v2-') as temp:
        binary = pathlib.Path(temp) / 'tests'
        subprocess.run(['clang', '-fobjc-arc', '-framework', 'Foundation', '-framework', 'AppKit',
                        '-I', str(api), str(root / 'Turn Touch Mac Tests/TTHueAPIClientTests.m'),
                        *[str(api / name) for name in ('TTHueAPIClient.m', 'TTHueModels.m', 'TTHueResourceCache.m')],
                        '-o', str(binary)], check=True)
        subprocess.run([str(binary), f'http://127.0.0.1:{server.server_port}'], check=True, timeout=70)
    assert requests == collections.Counter({path: 1 for path in (
        '/success', '/api-error', '/partial-error', '/malformed', '/unauthorized', '/redirect')})
    print('PASS: exact action payloads, no redirected credentials, and no action retries.')
finally:
    server.shutdown()
