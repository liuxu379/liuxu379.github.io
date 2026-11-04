#!/usr/bin/env python3
"""Build the complete LCSign source from separately maintained JSON shards."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "lcsign" / "sources"
parts = sorted(SRC.glob("part-*.json"))
if len(parts) != 14:
    raise RuntimeError(f"Expected 14 feed shards, got {len(parts)}")
apps = []
for part in parts:
    doc = json.loads(part.read_text(encoding="utf-8"))
    records = doc.get("apps", [])
    if not isinstance(records, list):
        raise ValueError(f"Invalid feed shard: {part.name}")
    apps.extend(records)
if not 6300 <= len(apps) <= 6400:
    raise RuntimeError(f"Unexpected application count: {len(apps)}")

def dump(path, obj):
    path.write_text(json.dumps(obj, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")

dump(ROOT / "lcsign" / "appstore.json", {
    "name": "个人应用资源索引",
    "message": "外部下载地址，部分链接可能过期。本站不托管安装包，不保证安全性或可用性。",
    "identifier": "org.resourceindex.ios.apps",
    "apps": apps,
})
entries = []
for a in apps:
    desc = a.get("versionDescription", "")
    ident = re.search(r"资源编号\s+(\d+)", desc)
    form = re.search(r"\b(IPA|TIPA)\b", desc)
    entries.append({
        "name": a.get("name", ""),
        "version": a.get("version", ""),
        "originalId": ident.group(1) if ident else "",
        "format": form.group(1).lower() if form else "ipa",
        "downloadURL": a.get("downloadURL", ""),
    })
dump(ROOT / "lcsign" / "catalog.json", {"name": "个人应用资源索引", "total": len(entries), "entries": entries})
dump(ROOT / "lcsign" / "stats.json", {
    "apps": len(entries),
    "ipa": sum(r["format"] == "ipa" for r in entries),
    "tipa": sum(r["format"] == "tipa" for r in entries),
    "shards": len(parts),
    "note": "第三方外链未逐一验证，文件大小与 Bundle ID 未知。"
})
print(f"LCSign feed built: {len(entries)} apps, {len(parts)} shards")
