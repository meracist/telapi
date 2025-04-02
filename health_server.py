#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = int(os.environ.get('HEALTH_CHECK_PORT', 10000))

class HealthCheckHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok","message":"Telegram Bot API Health Check"}')

    def log_message(self, format, *args):
        # Suppress logging to reduce noise
        pass

if __name__ == "__main__":
    handler = HealthCheckHandler
    with socketserver.TCPServer(("", PORT), handler) as httpd:
        print(f"Health Check Server running at port {PORT}")
        httpd.serve_forever()
