# Integration Tests

Integration tests that verify the deployed API endpoint works correctly.

## Prerequisites

1. Deployed API endpoint
2. `requests` library installed: `pip install requests`

## Running Tests

### Set API Endpoint

**Windows PowerShell:**
```powershell
$env:API_ENDPOINT = "https://your-api-id.execute-api.eu-north-1.amazonaws.com/dev"
pytest src/tests/integration/ -v
```

**Unix/Linux/Mac:**
```bash
export API_ENDPOINT="https://your-api-id.execute-api.eu-north-1.amazonaws.com/dev"
pytest src/tests/integration/ -v
```

### Get Your API Endpoint

```bash
cd infra
terraform output api_endpoint
```

## Test Categories

- **TestHeadEndpoint** - Tests for /v1/list/head
- **TestTailEndpoint** - Tests for /v1/list/tail
- **TestErrorHandling** - Validation and error responses
- **TestSecurityHeaders** - Security header verification
- **TestPerformance** - Response time and concurrency
- **TestThrottling** - Rate limiting behavior

## Running Specific Tests

```bash
# Run only error handling tests
pytest src/tests/integration/test_api_integration.py::TestErrorHandling -v

# Run only performance tests
pytest src/tests/integration/test_api_integration.py::TestPerformance -v

# Run with detailed output
pytest src/tests/integration/ -vv

# Skip slow tests
pytest src/tests/integration/ -v -m "not slow"
```

## CI/CD Integration

These tests are designed to run in the smoke test workflow after deployment.

See `.github/workflows/smoke.yml` for automated integration testing.
