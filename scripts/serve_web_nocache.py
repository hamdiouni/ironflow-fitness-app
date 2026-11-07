#!/usr/bin/env python3
"""No-cache SPA HTTP server for IronFlow Flutter Web builds on localhost."""

from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os
import sys


class NoCacheSPAHandler(SimpleHTTPRequestHandler):
    """Serves static web files with strict anti-cache headers and SPA routing."""

    screenshots_root = os.path.abspath(os.path.join("docs", "screenshots"))

    def end_headers(self) -> None:
        self.send_header(
            "Cache-Control",
            "no-store, no-cache, must-revalidate, max-age=0",
        )
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        super().end_headers()

    def translate_path(self, path: str) -> str:
        clean = path.split("?", 1)[0].split("#", 1)[0]
        if clean == "/screenshots" or clean.startswith("/screenshots/"):
            rel = clean[len("/screenshots") :].lstrip("/")
            if not rel:
                rel = "comparison.html"
            return os.path.join(self.screenshots_root, *rel.split("/"))
        return super().translate_path(path)

    def _apply_spa_fallback(self) -> None:
        path = self.translate_path(self.path)
        if not os.path.exists(path):
            clean = self.path.split("?", 1)[0].split("#", 1)[0]
            if not clean.startswith("/screenshots/"):
                _, ext = os.path.splitext(clean)
                if not ext:
                    self.path = "/index.html"

    def do_GET(self) -> None:
        self._apply_spa_fallback()
        super().do_GET()

    def do_HEAD(self) -> None:
        self._apply_spa_fallback()
        super().do_HEAD()


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    directory = sys.argv[2] if len(sys.argv) > 2 else os.path.join("build", "web")
    handler = partial(NoCacheSPAHandler, directory=directory)
    server = ThreadingHTTPServer(("127.0.0.1", port), handler)
    print(
        f"IronFlow No-Cache SPA Server listening on http://localhost:{port} -> {directory}",
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
