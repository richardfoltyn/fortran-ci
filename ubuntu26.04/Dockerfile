# Build a reusable Ubuntu image with GNU Fortran toolchains, CMake, and
# repository BLAS/LAPACK for compiling and testing Fortran projects.

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
        build-essential ca-certificates cmake git gfortran ninja-build pkg-config \
        libblas-dev liblapack-dev ${compilers}; \
    rm -rf /var/lib/apt/lists/*

# Record resolved versions so CI artifacts can identify the toolchain precisely.
RUN mkdir -p /opt/fortran-ci; \
    printf '%s\n' ${GFORTRAN_VERSIONS} > /opt/fortran-ci/compiler-versions; \
    dpkg-query -W > /opt/fortran-ci/packages.tsv

# Bound thread counts and build parallelism; jobs can override these variables.
ENV OMP_NUM_THREADS=2 \
    OPENBLAS_NUM_THREADS=1 \
    CMAKE_BUILD_PARALLEL_LEVEL=4
WORKDIR /work
CMD ["bash"]
