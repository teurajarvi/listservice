PY := python3

.PHONY: package clean test sync-docs

package:
	$(PY) scripts/build_zip.py

clean:
	rm -rf build

test:
	$(PY) -m pytest -q

sync-docs:
	@echo "Syncing openapi.yaml to docs/ folder..."
	@cp openapi.yaml docs/openapi.yaml
	@echo "✅ Done! openapi.yaml synced to docs/"
	@echo "💡 Run 'git add docs/openapi.yaml' to commit the change"
