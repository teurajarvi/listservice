import os
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
BUILD = ROOT / "build"
ZIP_PATH = BUILD / "listservice.zip"

def main():
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in SRC.rglob("*.py"):
            arcname = p.relative_to(ROOT)  # keep src/ prefix
            zf.write(p, arcname)

    print(f"Built {ZIP_PATH}")

if __name__ == "__main__":
    main()
