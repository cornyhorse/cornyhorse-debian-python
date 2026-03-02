# python-base

PGO + LTO optimized **CPython** Docker base images built on **Debian Bookworm (slim)**.

Published to GitHub Container Registry for **linux/amd64** and **linux/arm64**.
Consumed by the [trombbone](https://github.com/cornyhorse/trombbone) project.

## Available versions

| Python | Pull command |
|--------|--------------|
| 3.14 | `docker pull ghcr.io/cornyhorse/python-base:3.14` |
| 3.13 | `docker pull ghcr.io/cornyhorse/python-base:3.13` |
| 3.12 | `docker pull ghcr.io/cornyhorse/python-base:3.12` |

The `:latest` tag always points to the latest **3.14** build.

## Quick start

```dockerfile
FROM ghcr.io/cornyhorse/python-base:3.14

COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "main.py"]
```

## What's included

- CPython compiled from source with `--enable-optimizations` (PGO), `--with-lto`, and `--with-computed-gotos`
- Multi-arch: `linux/amd64` and `linux/arm64`
- Python installed to `/opt/python` with `/opt/python/bin` on `PATH`
- pip, setuptools, and wheel pre-installed
- Environment variables: `PYTHONUNBUFFERED=1`, `PYTHONDONTWRITEBYTECODE=1`, `LANG=C.UTF-8`
- No compiler toolchain in the final image — only runtime shared libraries

## Available tags

| Tag | Description |
|-----|-------------|
| `3.14` | Latest 3.14.x build (rolling) |
| `3.13` | Latest 3.13.x build (rolling) |
| `3.12` | Latest 3.12.x build (rolling) |
| `3.14.x` | Specific patch version (e.g., `3.14.2`) |
| `3.13.x` | Specific patch version (e.g., `3.13.3`) |
| `3.12.x` | Specific patch version (e.g., `3.12.9`) |
| `latest` | Alias for `3.14` |

All tags are multi-arch manifests covering `linux/amd64` and `linux/arm64`.

## Build args

| Arg | Default | Purpose |
|-----|---------|---------|
| `PYTHON_VERSION` | `3.14.2` | CPython release to compile |
| `DEBIAN_VERSION` | `bookworm` | Debian suite for the base image |

## Automated builds

- **Weekly** (Sunday 4:00 AM UTC): Checks [python.org/ftp](https://www.python.org/ftp/python/) for new CPython 3.12.x, 3.13.x, and 3.14.x releases. Builds `linux/amd64` only. Skips versions already published.
- **Monthly** (1st of month, 4:00 AM UTC): Same detection, but builds both `linux/amd64` and `linux/arm64`.
- **Release**: Push a tag like `v3.14.2`, `v3.13.3`, or `v3.12.9` to trigger a multi-arch build for that specific version.
- **Push to main**: Any push to `main` triggers an amd64 build for all three version series.
- **Manual dispatch**: Trigger from Actions tab with a choice of `linux/amd64` or `linux/amd64,linux/arm64`.

## Package visibility

After the first image push, the GHCR package defaults to **private**. To allow
unauthenticated pulls:

1. Go to `https://github.com/users/cornyhorse/packages/container/python-base/settings`
2. Under **Danger Zone**, change visibility to **Public**

## License

MIT