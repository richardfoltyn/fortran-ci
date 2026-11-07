# Build a reusable image with GNU/Intel Fortran and reference/Intel BLAS/LAPACK.

ARG UBUNTU_IMAGE=ubuntu:26.04
FROM ${UBUNTU_IMAGE}

# Native versions available in Ubuntu 26.04, including Universe.
# Install matching C compilers for mixed C/Fortran projects.
ARG GFORTRAN_VERSIONS="11 12 13 14 15 16"

# Keep sources and project-specific test helpers outside this reusable image.
# The unversioned gcc/gfortran commands retain Ubuntu's default compiler.
RUN set -eu; \
    apt-get update; \
    compilers=""; \
    for version in ${GFORTRAN_VERSIONS}; do \
        compilers="${compilers} gcc-${version} gfortran-${version}"; \
    done; \
    apt-get install -y --no-install-recommends \
        build-essential ca-certificates cmake curl git gnupg gfortran ninja-build pkg-config \
        libblas-dev liblapack-dev ${compilers}; \
    rm -rf /var/lib/apt/lists/*

# Select release series independently; APT resolves available patch versions.
ARG IFX_VERSION=2026.2
ARG MKL_VERSION=2026.2
RUN set -eu; \
    curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        -o /tmp/oneapi-key.asc; \
    gpg --batch --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg /tmp/oneapi-key.asc; \
    rm /tmp/oneapi-key.asc; \
    printf '%s\n' 'deb [arch=amd64 signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main' \
        > /etc/apt/sources.list.d/oneapi.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "intel-oneapi-compiler-fortran-${IFX_VERSION}" \
        "intel-oneapi-mkl-classic-devel-${MKL_VERSION}"; \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=755 with-oneapi.sh /usr/local/bin/with-oneapi

# Record resolved versions so CI artifacts can identify the toolchain precisely.
RUN mkdir -p /opt/fortran-ci; \
    printf '%s\n' ${GFORTRAN_VERSIONS} > /opt/fortran-ci/compiler-versions; \
    dpkg-query -W > /opt/fortran-ci/packages.tsv

# Bound thread counts and build parallelism; jobs can override these variables.
ENV OMP_NUM_THREADS=2 \
    MKL_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1 \
    CMAKE_BUILD_PARALLEL_LEVEL=4
WORKDIR /work
CMD ["bash"]
