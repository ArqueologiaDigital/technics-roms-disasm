#!/usr/bin/env python3
"""The only channel between the host and the throwaway compile VM (run_vm.sh).

usage: python3 -I httpd.py SERVE_DIR OUT_DIR PORT
Binds 127.0.0.1:PORT, which the QEMU user-mode guest reaches as 10.0.2.2:PORT.
- GET /<name>       serves SERVE_DIR/<name> (cloud-init's user-data / meta-data, the job script, the input tarball);
- PUT /out/<name>   writes the request body to OUT_DIR/<name>.
<name> must be a bare file name ([A-Za-z0-9._-]+): no directories, so the guest can neither read nor write
anything outside those two directories.
"""
import http.server, os, re, sys

SERVE, OUT, PORT = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2]), int(sys.argv[3])
NAME = re.compile(r'^[A-Za-z0-9._-]+$')

class H(http.server.BaseHTTPRequestHandler):
    def _name(self, prefix):
        p = self.path.split('?', 1)[0]
        if not p.startswith(prefix): return None
        n = p[len(prefix):]
        return n if NAME.match(n) and n not in ('.', '..') else None

    def do_GET(self):
        n = self._name('/')
        f = n and os.path.join(SERVE, n)
        if not f or not os.path.isfile(f):
            self.send_error(404); return
        data = open(f, 'rb').read()
        self.send_response(200)
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_PUT(self):
        n = self._name('/out/')
        if not n:
            self.send_error(403); return
        size = int(self.headers.get('Content-Length', '0'))
        with open(os.path.join(OUT, n), 'wb') as fh:
            left = size
            while left:
                b = self.rfile.read(min(left, 1 << 20))
                if not b: break
                fh.write(b); left -= len(b)
        self.send_response(201); self.send_header('Content-Length', '0'); self.end_headers()

http.server.ThreadingHTTPServer(('127.0.0.1', PORT), H).serve_forever()
