# python-base

PGO + LTO optimized **CPython 3.14** Docker base image built on **Debian Bookworm (slim)**.

Published to GitHub Container Registry and consumed by the [trombbone](https://github.com/cornyhorse/trombbone) project.

## Quick start

```bash
docker pull ghcr.io/cornyhorse/python-base:3.14
```

Use it in a Dockerfile:

```dockerfile
FROM ghcr.io/cornyhorse/python-base:3.14

COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "main.py"]
```

## What's included

- CPython compiled from source with `--enable-optimizations` (PGO), `--with-lto`, and `--with-computed-gotos`
- Python installed to `/opt/python` with `/opt/python/bin` on `PATH`
- pip, setuptools, and wheel pre-installed
- Environment variables: `PYTHONUNBUFFERED=1`, `PYTHONDONTWRITEBYTECODE=1`, `LANG=C.UTF-8`
- No compiler toolchain in the final image — only runtime shared libraries

## Available tags

| Tag | Description |
|-----|-------------|
| `3.14` | Latest 3.14.x build (rolling) |
| `3.14.x` | Specific patch version (e.g., `3.14.2`) |
| `latest` | Alias for `3.14` |

## Build args

| Arg | Default | Purpose |
|-----|---------|---------|
| `PYTHON_VERSION` | `3.14.2` | CPython release to compile |
| `DEBIAN_VERSION` | `bookworm` | Debian suite for the base image |

## Automated builds

- **Nightly** (4:00 AM UTC): Checks [python.org/ftp](https://www.python.org/ftp/python/) for new CPython 3.14.x releases. Builds and pushes only when a new patch version is detected. Can also be triggered manually via `workflow_dispatch`.
- **Release**: Push a tag like `v3.14.2` to trigger a build for that specific version.
- **Push to main**: Any push to `main` triggers a build with the latest detected version.

## Package visibility

After the first image push, the GHCR package defaults to **private**. To allow
unauthenticated pulls:

1. Go to `https://github.com/users/cornyhorse/packages/container/python-base/settings`
2. Under **Danger Zone**, change visibility to **Public**

## License

MIT