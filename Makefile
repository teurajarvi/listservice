PY := python3

.PHONY: package clean test test-integration test-all coverage sync-docs

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

coverage:
	$(PY) -m pytest src/tests/test_handler.py \
		--cov=src \
		--cov-report=term-missing \
		--cov-report=html \
		--cov-report=xml
	@echo "\n✅ Coverage report generated:"
	@echo "   - Terminal: see above"
	@echo "   - HTML: open htmlcov/index.html"
	@echo "   - XML: coverage.xml"

sync-docs:
	@echo "Syncing openapi.yaml to docs/ folder..."
	@cp openapi.yaml docs/openapi.yaml
	@echo "✅ Done! openapi.yaml synced to docs/"
	@echo "💡 Run 'git add docs/openapi.yaml' to commit the change"
