import json
import src.handler as handler


def _event(path: str, body: dict, method: str = "POST"):
    return {
        "requestContext": {"http": {"path": path, "method": method}},
        "body": json.dumps(body),
    }


def test_head_operation():
    e = _event("/v1/list/head", {"list": ["a", "b", "c"], "n": 2})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["a", "b"]


def test_tail_operation():
    e = _event("/v1/list/tail", {"list": ["a", "b", "c"], "n": 2})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["b", "c"]


def test_head_default_n():
    """Test head with default n=1"""
    e = _event("/v1/list/head", {"list": ["a", "b", "c"]})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["a"]


def test_tail_default_n():
    """Test tail with default n=1"""
    e = _event("/v1/list/tail", {"list": ["a", "b", "c"]})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["c"]


def test_tail_n_greater_than_list_length():
    """Test tail when n > list length - should return entire list"""
    e = _event("/v1/list/tail", {"list": ["a", "b"], "n": 10})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["a", "b"]


def test_head_n_greater_than_list_length():
    """Test head when n > list length - should return entire list"""
    e = _event("/v1/list/head", {"list": ["x", "y"], "n": 100})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["x", "y"]


def test_empty_list():
    """Test operations on empty list"""
    e = _event("/v1/list/head", {"list": [], "n": 1})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == []

    e = _event("/v1/list/tail", {"list": []})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == []


def test_single_item_list():
    """Test operations on single item list"""
    e = _event("/v1/list/head", {"list": ["solo"], "n": 1})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["solo"]


def test_validation_errors():
    # Missing list field
    e = _event("/v1/list/head", {"n": 5})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400

    # List is not an array
    e = _event("/v1/list/head", {"list": "nope"})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400

    # List contains non-string
    e = _event("/v1/list/head", {"list": ["ok", 1]})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400

    # n is zero
    e = _event("/v1/list/head", {"list": ["a"], "n": 0})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400

    # n is negative
    e = _event("/v1/list/tail", {"list": ["a"], "n": -5})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400

    # n is too large
    e = _event("/v1/list/head", {"list": ["a"], "n": 10001})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400

    # n is not an integer
    e = _event("/v1/list/tail", {"list": ["a"], "n": "five"})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400


def test_invalid_json_body():
    """Test malformed JSON in request body"""
    event = {
        "requestContext": {"http": {"path": "/v1/list/head", "method": "POST"}},
        "body": "not valid json {{{",
    }
    r = handler.lambda_handler(event, None)
    assert r["statusCode"] == 400
    body = json.loads(r["body"])
    assert "error" in body


def test_method_not_allowed():
    """Test non-POST methods"""
    e = _event("/v1/list/head", {"list": ["a"]}, method="GET")
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 405
    body = json.loads(r["body"])
    assert "Method Not Allowed" in body["error"]

    e = _event("/v1/list/tail", {"list": ["a"]}, method="DELETE")
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 405


def test_unknown_path():
    """Test request to unknown endpoint"""
    e = _event("/v1/list/unknown", {"list": ["a"]})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 404
    body = json.loads(r["body"])
    assert "Not Found" in body["error"]


def test_large_list():
    """Test with a larger list"""
    large_list = [f"item-{i}" for i in range(1000)]
    
    e = _event("/v1/list/head", {"list": large_list, "n": 10})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert len(body["result"]) == 10
    assert body["result"][0] == "item-0"
    assert body["result"][-1] == "item-9"

    e = _event("/v1/list/tail", {"list": large_list, "n": 5})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert len(body["result"]) == 5
    assert body["result"][0] == "item-995"
    assert body["result"][-1] == "item-999"


def test_case_insensitive_path():
    """Test that paths are handled case-insensitively"""
    e = _event("/V1/LIST/HEAD", {"list": ["a", "b"]})
    r = handler.lambda_handler(e, None)
    body = json.loads(r["body"])
    assert r["statusCode"] == 200
    assert body["result"] == ["a"]


def test_list_too_long():
    """Test that list exceeding MAX_LIST_LENGTH is rejected"""
    too_long_list = [f"item-{i}" for i in range(10001)]
    e = _event("/v1/list/head", {"list": too_long_list, "n": 1})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400
    body = json.loads(r["body"])
    assert "10000" in body["error"]


def test_string_too_long():
    """Test that strings exceeding MAX_STRING_LENGTH are rejected"""
    long_string = "a" * 1001  # Exceeds MAX_STRING_LENGTH of 1000
    e = _event("/v1/list/head", {"list": [long_string], "n": 1})
    r = handler.lambda_handler(e, None)
    assert r["statusCode"] == 400
    body = json.loads(r["body"])
    assert "max length" in body["error"].lower()


def test_body_too_large():
    """Test that request body exceeding MAX_BODY_SIZE is rejected"""
    # Create a large list to exceed 1 MB
    large_list = ["x" * 1000 for _ in range(2000)]  # ~2 MB of data
    event = {
        "requestContext": {"http": {"path": "/v1/list/head", "method": "POST"}},
        "body": json.dumps({"list": large_list, "n": 1}),
    }
    r = handler.lambda_handler(event, None)
    assert r["statusCode"] == 400
    body = json.loads(r["body"])
    assert "too large" in body["error"].lower()
