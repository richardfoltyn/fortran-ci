# Fortran CI

Reusable Docker build environments for local tests and CI services.
Project sources and test scripts are mounted into the containers.

## Ubuntu 26.04

- GCC/gfortran 11–16, with matching C and Fortran compilers.
- CMake, Ninja, Make, Git, and repository BLAS/LAPACK development packages.
- Default compiler: GCC 15. GCC 16 is the `16-20260322` development snapshot.
- Package inventory: `/opt/fortran-ci/packages.tsv` inside the image.

Build from this repository:

```sh
docker pull ubuntu:26.04
docker build -t fortran-ci:ubuntu26.04 ubuntu26.04
```

Run from a project checkout, selecting matching compilers explicitly:

```sh
mkdir -p build-ci
docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/src:ro,z" \
    -v "$(pwd)/build-ci:/build:z" \
    fortran-ci:ubuntu26.04 bash -e -c '
        cmake -S /src -B /build/gnu-15 -G Ninja \
            -DCMAKE_C_COMPILER=gcc-15 -DCMAKE_Fortran_COMPILER=gfortran-15
        cmake --build /build/gnu-15 &&
        ctest --test-dir /build/gnu-15 --output-on-failure
    '
```

- Each project owns its test runner and dependency checkouts.
- Use separate build/install directories for each compiler and configuration;
  Fortran module files depend on the compiler version.
- `:z` supports SELinux hosts and sharing mounts across jobs.
- Build parallelism defaults to 4; OpenMP threads default to 2. Override with `-e`.
- Local Docker images persist and ordinary rebuilds reuse cached layers.
- Refresh with `docker build --pull --no-cache`; pin `UBUNTU_IMAGE` to a digest
  and retain the resulting tools image digest when repeatability is required.

Verified Ubuntu 26.04 amd64 compiler packages:

| Compiler | Repository version |
| --- | --- |
| 11 | 11.5.0-11ubuntu2 |
| 12 | 12.5.0-9ubuntu1 |
| 13 | 13.4.0-10ubuntu1 |
| 14 | 14.3.0-14ubuntu1 |
| 15 | 15.2.0-16ubuntu1 |
| 16 | 16-20260322-1ubuntu1 |
