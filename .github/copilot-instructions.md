# Copilot Instructions — cornyhorse-debian-python

## Project overview
This repository builds and publishes a **PGO+LTO optimized CPython 3.14** Docker
base image to GitHub Container Registry (`ghcr.io/cornyhorse/python-base`).
The image is consumed by the **trombbone** project as:

```dockerfile
FROM ghcr.io/cornyhorse/python-base:3.14
```

## Repository layout

```
Dockerfile                     # Two-stage build: builder → runtime
.dockerignore
.github/
  workflows/
    nightly.yml                # Cron + push + manual trigger
    release.yml                # Tag-triggered release build
README.md
```

## Image conventions
- Python is installed to **`/opt/python`**; `/opt/python/bin` is on `PATH`.
- pip, setuptools, and wheel are pre-installed.
- Environment: `PYTHONUNBUFFERED=1`, `PYTHONDONTWRITEBYTECODE=1`, `LANG=C.UTF-8`.
- Base OS: Debian Bookworm (slim).
- No compiler toolchain in the final image — only runtime shared libraries.

## Dockerfile build args
| Arg              | Default   | Purpose                        |
|------------------|-----------|--------------------------------|
| PYTHON_VERSION   | 3.14.2    | CPython release to compile     |
| DEBIAN_VERSION   | bookworm  | Debian suite for base image    |

## Workflow design
- **nightly.yml**: runs at 04:00 UTC, also on push to `main` and `workflow_dispatch`.
  Detects the latest CPython 3.14.x release from python.org FTP; skips the build
  if the version already matches the published `:3.14` tag (unless manually dispatched).
- **release.yml**: triggered by pushing a tag like `v3.14.2`. Always builds and pushes.

Both workflows:
- Use `docker/build-push-action` with `linux/amd64` platform.
- Authenticate to ghcr.io with `GITHUB_TOKEN`.
- Use GitHub Actions cache (`type=gha`).
- Tag the image as `:3.14`, `:<specific-version>`, and `:latest`.
- Add OCI `org.opencontainers.image.*` labels.

## Coding guidelines
- Keep the Dockerfile layer-efficient; combine `apt-get` commands, remove caches.
- In workflows, pin third-party actions to a major version tag (e.g., `@v4`).
- Use `${{ github.repository_owner }}` in image references to remain fork-friendly.
- When editing the Dockerfile, preserve the two-stage pattern and `/opt/python` path.
- All shell in workflows should use `set -euo pipefail`.
- Prefer `curl` over `wget` in workflows for consistency with the Dockerfile.
