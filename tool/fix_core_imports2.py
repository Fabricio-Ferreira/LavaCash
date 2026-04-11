#!/usr/bin/env python3
"""Fix feature entity paths and presentation->data repository imports."""

import re
from pathlib import Path

REPLACEMENTS = (
    ("package:lava_cash/core/domain/entities/expense.dart",
     "package:lava_cash/core/domain/expense/entities/expense.dart"),
    ("package:lava_cash/core/domain/entities/empresa.dart",
     "package:lava_cash/core/domain/empresa/entities/empresa.dart"),
    ("package:lava_cash/core/domain/entities/user_session.dart",
     "package:lava_cash/core/domain/auth/entities/user_session.dart"),
    ("package:lava_cash/core/domain/entities/update_info.dart",
     "package:lava_cash/core/domain/app_update/entities/update_info.dart"),
    ("package:lava_cash/core/domain/entities/update_check_result.dart",
     "package:lava_cash/core/domain/app_update/entities/update_check_result.dart"),
)


def fix_file(path: Path) -> bool:
    t = path.read_text(encoding="utf-8")
    o = t
    for a, b in REPLACEMENTS:
        t = t.replace(a, b)

    t = re.sub(
        r"import\s+['\"]\.\./\.\./data/repositories/([^'\"]+)['\"]\s*;",
        r"import 'package:lava_cash/core/data/\1';",
        t,
    )

    m = re.match(r"^lib/features/([^/]+)/presentation/", str(path).replace("\\", "/"))
    if m:
        feat = m.group(1)
        if feat not in ("dashboard", "license", "app_update"):
            pass
        t = re.sub(
            rf"import\s+['\"]\.\./\.\./data/repositories/({feat}_repository_impl\.dart)['\"]\s*;",
            rf"import 'package:lava_cash/core/data/{feat}/repositories/\1';",
            t,
        )

    t = re.sub(
        r"import\s+['\"]\.\./\.\./data/repositories/([^'\"]+)['\"]\s*;",
        r"import 'package:lava_cash/core/data/\1';",
        t,
    )

    if t != o:
        path.write_text(t, encoding="utf-8")
        return True
    return False


def main() -> None:
    n = 0
    for path in sorted(Path("lib").rglob("*.dart")):
        if fix_file(path):
            n += 1
    print(f"pass2 updated {n} files")


if __name__ == "__main__":
    main()
