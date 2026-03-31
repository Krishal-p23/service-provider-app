import logging
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen


class SolarWindsHTTPLogHandler(logging.Handler):
    """Send log records to SolarWinds/Papertrail token-based HTTPS ingest."""

    def __init__(self, token: str, endpoint: str, timeout: float = 2.0):
        super().__init__()
        self.token = (token or '').strip()
        self.endpoint = (endpoint or '').strip()
        self.timeout = timeout

    def emit(self, record: logging.LogRecord) -> None:
        if not self.token or not self.endpoint:
            return

        try:
            message = self.format(record)
            payload = message.encode('utf-8')
            request = Request(
                self.endpoint,
                data=payload,
                headers={
                    'Content-Type': 'application/octet-stream',
                    'Authorization': f'Bearer {self.token}',
                },
                method='POST',
            )
            with urlopen(request, timeout=self.timeout):
                pass
        except (URLError, HTTPError, TimeoutError, OSError):
            self.handleError(record)
