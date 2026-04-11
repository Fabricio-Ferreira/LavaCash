#!/usr/bin/env python3
"""Rewrite imports after moving feature data/domain into lib/core/data|domain."""

import re
import sys
from pathlib import Path

FEATURES = (
    "auth",
    "app_update",
    "empresa",
    "expense",
    "license",
    "payment",
    "registration",
    "reports",
    "search",
    "service",
)


def core_data_feature(path: Path) -> str | None:
    parts = path.parts
    for i, p in enumerate(parts):
        if p == "data" and i + 1 < len(parts) and parts[i - 1] == "core":
            if parts[i + 1] in FEATURES:
                return parts[i + 1]
    return None


def core_domain_feature(path: Path) -> str | None:
    parts = path.parts
    for i, p in enumerate(parts):
        if p == "domain" and i + 1 < len(parts) and parts[i - 1] == "core":
            n = parts[i + 1]
            if n in FEATURES:
                return n
    return None


def feature_from_features_path(path: Path) -> str | None:
    parts = path.parts
    if len(parts) >= 3 and parts[0] == "lib" and parts[1] == "features":
        if parts[2] in FEATURES:
            return parts[2]
    return None


def process(content: str, path: Path) -> str:
    t = content

    t = t.replace(
        "package:lava_cash/domain/entities/",
        "package:lava_cash/core/domain/entities/",
    )

    t = re.sub(
        r"import\s+['\"](?:\.\./)+domain/entities/([^'\"]+)['\"]\s*;",
        r"import 'package:lava_cash/core/domain/entities/\1';",
        t,
    )

    cdf = core_data_feature(path)
    if cdf is not None:
        t = re.sub(
            r"import\s+['\"]\.\./\.\./domain/([^'\"]+)['\"]\s*;",
            rf"import 'package:lava_cash/core/domain/{cdf}/\1';",
            t,
        )
        t = re.sub(
            r"import\s+['\"]\.\./\.\./\.\./\.\./domain/entities/([^'\"]+)['\"]\s*;",
            r"import 'package:lava_cash/core/domain/entities/\1';",
            t,
        )

    cdf_dom = core_domain_feature(path)
    if cdf_dom is not None:
        t = re.sub(
            r"import\s+['\"](?:\.\./)+domain/entities/([^'\"]+)['\"]\s*;",
            r"import 'package:lava_cash/core/domain/entities/\1';",
            t,
        )
        t = re.sub(
            r"import\s+['\"]\.\./\.\./\.\./\.\./domain/entities/([^'\"]+)['\"]\s*;",
            r"import 'package:lava_cash/core/domain/entities/\1';",
            t,
        )

    ff = feature_from_features_path(path)
    if ff is not None:
        t = re.sub(
            r"import\s+['\"](?:\.\./)+domain/([^'\"]+)['\"]\s*;",
            rf"import 'package:lava_cash/core/domain/{ff}/\1';",
            t,
        )

    for feat in FEATURES:
        t = re.sub(
            rf"import\s+['\"](?:\.\./)+{feat}/data/([^'\"]+)['\"]\s*;",
            rf"import 'package:lava_cash/core/data/{feat}/\1';",
            t,
        )
        t = re.sub(
            rf"import\s+['\"](?:\.\./)+{feat}/domain/([^'\"]+)['\"]\s*;",
            rf"import 'package:lava_cash/core/domain/{feat}/\1';",
            t,
        )
        t = re.sub(
            rf"import\s+['\"](?:\.\./)+{feat}/presentation/([^'\"]+)['\"]\s*;",
            rf"import 'package:lava_cash/features/{feat}/presentation/\1';",
            t,
        )

    if str(path).startswith("lib/data/"):
        t = re.sub(
            r"import\s+['\"]\.\./\.\./domain/entities/([^'\"]+)['\"]\s*;",
            r"import 'package:lava_cash/core/domain/entities/\1';",
            t,
        )

    return t


def main() -> None:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("lib")
    n = 0
    for path in sorted(root.rglob("*.dart")):
        orig = path.read_text(encoding="utf-8")
        new = process(orig, path)
        if new != orig:
            path.write_text(new, encoding="utf-8")
            n += 1
    print(f"updated {n} files")


if __name__ == "__main__":
    main()
