"""
Integration tests for ListService API.
These tests require a deployed API endpoint.

Usage:
  export API_ENDPOINT="https://your-api-id.execute-api.region.amazonaws.com/dev"
  pytest src/tests/integration/ -v

Or on Windows:
  $env:API_ENDPOINT="https://your-api-id.execute-api.region.amazonaws.com/dev"
  pytest src/tests/integration/ -v
"""

import os
import pytest
import requests
import time
from typing import Dict, Any

# Get API endpoint from environment
API_ENDPOINT = os.getenv("API_ENDPOINT")

# Skip all tests if API_ENDPOINT is not set
pytestmark = pytest.mark.skipif(
    not API_ENDPOINT,
    reason="API_ENDPOINT environment variable not set. Set it to run integration tests."
)


def make_request(endpoint: str, payload: Dict[str, Any]) -> requests.Response:
    """Helper to make POST requests to the API"""
    url = f"{API_ENDPOINT}{endpoint}"
    headers = {"Content-Type": "application/json"}
    return requests.post(url, json=payload, headers=headers)


class TestHeadEndpoint:
    """Integration tests for /v1/list/head endpoint"""

    def test_head_basic(self):
        """Test basic HEAD operation"""
        response = make_request("/v1/list/head", {
            "list": ["apple", "banana", "cherry", "date"],
            "n": 2
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == ["apple", "banana"]

    def test_head_larger_list(self):
        """Test HEAD with larger list"""
        large_list = [f"item-{i}" for i in range(100)]
        response = make_request("/v1/list/head", {
            "list": large_list,
            "n": 10
        })
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["result"]) == 10
        assert data["result"][0] == "item-0"
        assert data["result"][-1] == "item-9"

    def test_head_n_exceeds_length(self):
        """Test HEAD when n > list length"""
        response = make_request("/v1/list/head", {
            "list": ["a", "b"],
            "n": 10
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == ["a", "b"]

    def test_head_empty_list(self):
        """Test HEAD with empty list"""
        response = make_request("/v1/list/head", {
            "list": [],
            "n": 5
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == []


class TestTailEndpoint:
    """Integration tests for /v1/list/tail endpoint"""

    def test_tail_basic(self):
        """Test basic TAIL operation"""
        response = make_request("/v1/list/tail", {
            "list": ["apple", "banana", "cherry", "date"],
            "n": 2
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == ["cherry", "date"]

    def test_tail_larger_list(self):
        """Test TAIL with larger list"""
        large_list = [f"item-{i}" for i in range(100)]
        response = make_request("/v1/list/tail", {
            "list": large_list,
            "n": 5
        })
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["result"]) == 5
        assert data["result"][0] == "item-95"
        assert data["result"][-1] == "item-99"

    def test_tail_n_exceeds_length(self):
        """Test TAIL when n > list length"""
        response = make_request("/v1/list/tail", {
            "list": ["x", "y"],
            "n": 100
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == ["x", "y"]


class TestErrorHandling:
    """Integration tests for error handling"""

    def test_missing_list_field(self):
        """Test request with missing 'list' field"""
        response = make_request("/v1/list/head", {"n": 5})
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data

    def test_invalid_list_type(self):
        """Test request with invalid list type"""
        response = make_request("/v1/list/head", {
            "list": "not-an-array",
            "n": 2
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data
        assert "array" in data["error"].lower()

    def test_non_string_elements(self):
        """Test request with non-string elements"""
        response = make_request("/v1/list/head", {
            "list": [1, 2, 3],
            "n": 2
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data
        assert "string" in data["error"].lower()

    def test_negative_n(self):
        """Test request with negative n"""
        response = make_request("/v1/list/tail", {
            "list": ["a", "b"],
            "n": -5
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data

    def test_zero_n(self):
        """Test request with n=0"""
        response = make_request("/v1/list/head", {
            "list": ["a", "b"],
            "n": 0
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data

    def test_n_too_large(self):
        """Test request with n > 10000"""
        response = make_request("/v1/list/head", {
            "list": ["a"],
            "n": 10001
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data

    def test_list_too_long(self):
        """Test request with list exceeding MAX_LIST_LENGTH"""
        too_long = [f"item-{i}" for i in range(10001)]
        response = make_request("/v1/list/head", {
            "list": too_long,
            "n": 1
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data
        assert "10000" in data["error"]

    def test_string_too_long(self):
        """Test request with string exceeding MAX_STRING_LENGTH"""
        long_string = "a" * 1001
        response = make_request("/v1/list/head", {
            "list": [long_string],
            "n": 1
        })
        
        assert response.status_code == 400
        data = response.json()
        assert "error" in data
        assert "max length" in data["error"].lower()

    def test_invalid_endpoint(self):
        """Test request to non-existent endpoint"""
        response = make_request("/v1/list/unknown", {
            "list": ["a"],
            "n": 1
        })
        
        assert response.status_code == 404

    def test_get_method_not_allowed(self):
        """Test that GET method is not allowed"""
        url = f"{API_ENDPOINT}/v1/list/head"
        response = requests.get(url)
        
        # Should return 404 (no route) or 405 (method not allowed)
        assert response.status_code in [404, 405]


class TestSecurityHeaders:
    """Integration tests for security headers"""

    def test_security_headers_present(self):
        """Test that security headers are present in response"""
        response = make_request("/v1/list/head", {
            "list": ["a", "b"],
            "n": 1
        })
        
        headers = response.headers
        
        # Check for security headers
        assert "X-Content-Type-Options" in headers
        assert headers["X-Content-Type-Options"] == "nosniff"
        
        assert "X-Frame-Options" in headers
        assert headers["X-Frame-Options"] == "DENY"
        
        assert "Strict-Transport-Security" in headers
        
        assert "Content-Security-Policy" in headers


class TestPerformance:
    """Integration tests for performance"""

    def test_response_time(self):
        """Test that response time is reasonable"""
        start = time.time()
        response = make_request("/v1/list/head", {
            "list": ["a", "b", "c"],
            "n": 2
        })
        elapsed = time.time() - start
        
        assert response.status_code == 200
        # Response should be under 2 seconds (generous for cold starts)
        assert elapsed < 2.0, f"Response took {elapsed:.2f}s"

    def test_concurrent_requests(self):
        """Test that API can handle multiple requests"""
        import concurrent.futures
        
        def make_test_request():
            return make_request("/v1/list/head", {
                "list": ["a", "b", "c"],
                "n": 2
            })
        
        # Make 10 concurrent requests
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(make_test_request) for _ in range(10)]
            responses = [f.result() for f in futures]
        
        # All should succeed
        for response in responses:
            assert response.status_code == 200
            data = response.json()
            assert data["result"] == ["a", "b"]


class TestThrottling:
    """Integration tests for rate limiting/throttling"""

    @pytest.mark.slow
    def test_rate_limiting(self):
        """Test that API enforces rate limits (if configured)"""
        # Make many rapid requests
        responses = []
        for i in range(30):
            response = make_request("/v1/list/head", {
                "list": [f"item-{i}"],
                "n": 1
            })
            responses.append(response.status_code)
            time.sleep(0.01)  # Small delay
        
        # Most should succeed (200)
        success_count = sum(1 for code in responses if code == 200)
        
        # At least some requests should succeed
        assert success_count > 0, "No requests succeeded"
        
        # If rate limiting is strict, we might see 429 (Too Many Requests)
        # But for HTTP API with default settings, all might succeed
        throttled_count = sum(1 for code in responses if code == 429)
        
        print(f"Success: {success_count}, Throttled: {throttled_count}")
