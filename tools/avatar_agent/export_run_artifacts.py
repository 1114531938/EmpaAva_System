from __future__ import annotations

from _shim import add_src_to_path

add_src_to_path()

from avatar_system.pipeline.export_artifacts import main


if __name__ == "__main__":
    main()
