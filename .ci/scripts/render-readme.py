#!/usr/bin/env python3
import os
import re
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, select_autoescape

# repo info
repo_owner = os.environ.get("REPO_OWNER", os.environ.get("GITHUB_REPOSITORY_OWNER", ""))
repo_name = os.environ.get("REPO_NAME", os.environ.get("GITHUB_REPOSITORY", ""))  # "owner/repo"
default_branch = os.environ.get("DEFAULT_BRANCH", "main")

env = Environment(
    loader=FileSystemLoader(".ci/templates"),
    autoescape=select_autoescape()
)

OPENWRT_RE = re.compile(r'^\s*OPENWRT_VERSION\s*=\s*(.+?)\s*$')

def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")

def read_first_nonempty_line(path: Path) -> str:
    for line in read_text(path).splitlines():
        s = line.strip()
        if s:
            return s
    return ""

def parse_openwrt_version(env_sh_path: Path) -> str:
    if not env_sh_path.exists():
        return ""
    for line in read_text(env_sh_path).splitlines():
        m = OPENWRT_RE.match(line)
        if m:
            raw = m.group(1).strip()
            # strip quotes if present
            if (raw.startswith('"') and raw.endswith('"')) or (raw.startswith("'") and raw.endswith("'")):
                raw = raw[1:-1].strip()
            return raw
    return ""

def parse_packages(packages_path: Path) -> list[str]:
    if not packages_path.exists():
        return []
    pkgs = []
    for line in read_text(packages_path).splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        pkgs.append(s)
    return pkgs

def github_blob_url(repo: str, branch: str, rel_path: str) -> str:
    # nice clickable link for files in repo
    return f"https://github.com/{repo}/blob/{branch}/{rel_path}"

def build_routers():
    routers = []
    devices_dir = Path("devices")
    firmwares_dir = Path("firmwares")

    if not devices_dir.exists():
        return routers

    for router_dir in sorted([p for p in devices_dir.iterdir() if p.is_dir()], key=lambda p: p.name.lower()):
        router = router_dir.name

        packages_path = router_dir / "packages.txt"
        env_sh_path = router_dir / "env.sh"
        last_url_path = firmwares_dir / router / "last.url"

        openwrt_version = parse_openwrt_version(env_sh_path)
        packages = parse_packages(packages_path)
        release_url = read_first_nonempty_line(last_url_path) if last_url_path.exists() else ""

        routers.append({
            "name": router,
            "openwrt_version": openwrt_version,
            "packages": packages,
            "packages_count": len(packages),
            "release_url": release_url,

            # helpful file links in repo
            "packages_file_url": github_blob_url(repo_name, default_branch, f"devices/{router}/packages.txt"),
            "env_file_url": github_blob_url(repo_name, default_branch, f"devices/{router}/env.sh"),
            "last_url_file_url": github_blob_url(repo_name, default_branch, f"firmwares/{router}/last.url"),
        })

    return routers

if __name__ == "__main__":
    routers = build_routers()
    template = env.get_template("README.md.j2")
    with open("./README.md", "w", encoding="utf-8") as f:
        f.write(template.render(
            repo_name=repo_name,
            repo_owner=repo_owner,
            routers=routers
        ))
