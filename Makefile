PY := python3

.PHONY: package clean test sync-docs

package:
	$(PY) scripts/build_zip.py

clean:
	rm -rf build

test:
	$(PY) -m pytest src/tests/test_handler.py -q

test-integration:
	$(PY) -m pytest src/tests/integration/ -v

test-all:
	$(PY) -m pytest src/tests/ -v

sync-docs:
	@echo "Syncing openapi.yaml to docs/ folder..."
	@cp openapi.yaml docs/openapi.yaml
	@echo "✅ Done! openapi.yaml synced to docs/"
	@echo "💡 Run 'git add docs/openapi.yaml' to commit the change"
