## Basic Python-based Web Server with Python prometheus_client for instrumentation.

import http.server
from prometheus_client import start_http_server

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"\nThis is the python webserver.\nIt is designed for use with the prometheus_client.\nEnjoy your scraping!\n\n")

if __name__ == "__main__":
    start_http_server(8000)
    # Note: For remote monitoring, modify the server address 
    # from 'localhost' to the IP address of the system.
    server = http.server.HTTPServer(('localhost', 8001), MyHandler)
    server.serve_forever()
    