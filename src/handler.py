import json
import logging
import os
from typing import List, Tuple, Any, Dict

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=getattr(logging, LOG_LEVEL, logging.INFO))
logger = logging.getLogger(__name__)

# Security limits to prevent abuse and excessive resource usage
MAX_LIST_LENGTH = 10000  # Maximum number of items in the list
MAX_STRING_LENGTH = 1000  # Maximum length of each string in the list
MAX_BODY_SIZE = 1024 * 1024  # 1 MB max request body size


def _parse_body(event: Dict[str, Any]) -> Dict[str, Any]:
    body_raw = event.get("body") or "{}"
    
    # Check body size to prevent DoS attacks
    if len(body_raw) > MAX_BODY_SIZE:
        raise ValueError(f"Request body too large (max {MAX_BODY_SIZE} bytes)")
    
    try:
        return json.loads(body_raw)
    except json.JSONDecodeError as e:
        raise ValueError("Body must be valid JSON") from e


def _validate(payload: Dict[str, Any]) -> Tuple[List[str], int]:
    arr = payload.get("list")
    n = payload.get("n", 1)

    if not isinstance(arr, list):
        raise ValueError("'list' must be an array")
    
    # Check list length to prevent memory exhaustion
    if len(arr) > MAX_LIST_LENGTH:
        raise ValueError(f"'list' length must be <= {MAX_LIST_LENGTH}")
    
    if not all(isinstance(x, str) for x in arr):
        raise ValueError("'list' must contain only strings")
    
    # Check individual string lengths to prevent excessive memory usage
    for idx, item in enumerate(arr):
        if len(item) > MAX_STRING_LENGTH:
            raise ValueError(f"String at index {idx} exceeds max length of {MAX_STRING_LENGTH} characters")

    if not isinstance(n, int) or n <= 0:
        raise ValueError("'n' must be a positive integer")
    if n > 10000:
        raise ValueError("'n' must be <= 10000")

    return arr, n


def _resp(status: int, body: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            # Security headers
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "DENY",
            "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
            "Content-Security-Policy": "default-src 'none'",
            "X-XSS-Protection": "1; mode=block",
        },
        "body": json.dumps(body),
    }


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    http = (event.get("requestContext") or {}).get("http") or {}
    path = (http.get("path") or "").lower()
    method = (http.get("method") or "GET").upper()

    if method != "POST":
        return _resp(405, {"error": "Method Not Allowed"})

    try:
        payload = _parse_body(event)
        arr, n = _validate(payload)

        if path.endswith("/head"):
            result = arr[:n]
        elif path.endswith("/tail"):
            result = arr[-n:] if n <= len(arr) else arr
        else:
            return _resp(404, {"error": "Not Found"})

        return _resp(200, {"result": result})

    except ValueError as ve:
        logger.warning("validation error: %s", ve)
        return _resp(400, {"code": "VALIDATION_ERROR", "error": str(ve)})
    except Exception as e:
        logger.exception("unhandled error")
        return _resp(500, {"code": "INTERNAL_ERROR", "error": "Internal Server Error"})
