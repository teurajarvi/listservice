PY := python3

.PHONY: package clean test

package:
	$(PY) scripts/build_zip.py

clean:
	rm -rf build

test:
	$(PY) -m pytest -q
