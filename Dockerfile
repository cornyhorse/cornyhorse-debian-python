# ============================================================
# Stage 1: Builder — compile CPython with PGO + LTO
# ============================================================
ARG DEBIAN_VERSION=bookworm

FROM debian:${DEBIAN_VERSION} AS builder

ARG PYTHON_VERSION=3.14.2

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    libbz2-dev \
    libexpat1-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncurses-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    pkg-config \
    uuid-dev \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Download and extract CPython source
RUN curl -fsSL "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" \
  | tar xz -C /usr/src

WORKDIR /usr/src/Python-${PYTHON_VERSION}

# Configure with PGO, LTO, and computed gotos
RUN ./configure \
    --prefix=/opt/python \
    --enable-optimizations \
    --with-lto \
    --with-computed-gotos \
    --with-system-expat \
    --with-system-ffi \
    --enable-loadable-sqlite-extensions

# Build (PGO instrumentation + training + final build) and install
RUN make -j"$(nproc)" && make install

# Install pip, setuptools, wheel
RUN /opt/python/bin/python3 -m ensurepip --upgrade \
  && /opt/python/bin/pip3 install --no-cache-dir --upgrade \
       pip setuptools wheel

# Reduce image size: strip binaries, remove static libs, tests, caches
RUN find /opt/python/lib -type d -name 'test' -prune -exec rm -rf {} + 2>/dev/null || true \
  && find /opt/python/lib -type d -name 'tests' -prune -exec rm -rf {} + 2>/dev/null || true \
  && find /opt/python -type f -name '*.a' -delete \
  && find /opt/python -type f \( -name '*.so' -o -name '*.so.*' \) \
       -exec strip --strip-unneeded {} + 2>/dev/null || true \
  && find /opt/python -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true

# ============================================================
# Stage 2: Runtime — lean image with only shared libraries
# ============================================================
ARG DEBIAN_VERSION=bookworm

FROM debian:${DEBIAN_VERSION}-slim AS runtime

LABEL org.opencontainers.image.title="python-base" \
      org.opencontainers.image.description="PGO+LTO optimized CPython 3.14 on Debian Bookworm" \
      org.opencontainers.image.source="https://github.com/cornyhorse/cornyhorse-debian-python" \
      org.opencontainers.image.licenses="MIT"

# Install only runtime shared libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libbz2-1.0 \
    libexpat1 \
    libffi8 \
    libgdbm6 \
    liblzma5 \
    libncurses6 \
    libncursesw6 \
    libreadline8 \
    libsqlite3-0 \
    libssl3 \
    libuuid1 \
    zlib1g \
  && rm -rf /var/lib/apt/lists/*

# Copy compiled Python from builder
COPY --from=builder /opt/python /opt/python

# Environment
ENV PATH="/opt/python/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    LANG=C.UTF-8

# Verify installation
RUN python3 --version && pip3 --version

CMD ["python3"]
