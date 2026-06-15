from __future__ import annotations

import sys
from pathlib import Path

root = Path(__file__).resolve().parents[3]
src = root / "src"
if str(src) not in sys.path:
    sys.path.insert(0, str(src))

from avatar_system.tools.build_template_from_vhap import main


if __name__ == "__main__":
    main()
