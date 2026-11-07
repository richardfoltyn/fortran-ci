# Fortran CI

Reusable Docker build environments for local tests and CI services.
Project sources and test scripts are mounted into the containers.

## Ubuntu 26.04

- GCC/gfortran 11–16, with matching C and Fortran compilers.
- Intel ifx and CPU oneMKL development libraries (Linux amd64).
- CMake, Ninja, Make, Git, and repository BLAS/LAPACK development packages.
- Default compiler: GCC 15. GCC 16 is the `16-20260322` development snapshot.
- Package inventory: `/opt/fortran-ci/packages.tsv` inside the image.

Build from this repository:

```sh
docker pull ubuntu:26.04
docker build -t fortran-ci:ubuntu26.04 ubuntu26.04
```

### Intel versions and environment

- `IFX_VERSION` and `MKL_VERSION` both default to `2026.2`.
- Both arguments select a release series. APT installs the available patch
  version within that series.
- Override independently with `--build-arg IFX_VERSION=...` and
  `--build-arg MKL_VERSION=...` in the build command above.
- The MKL classic development package provides CPU C/Fortran libraries without
  the SYCL development stack. Package dependencies include Intel runtime tools.
- Transitive dependencies are resolved by APT; retain the image digest and
  `/opt/fortran-ci/packages.tsv` for the complete resolved environment.

Prefix Intel jobs with `with-oneapi`. It initializes Intel's environment,
including compiler paths, runtime library paths, and `MKLROOT`, then executes
the command. It works with noninteractive shells and arbitrary container users:

```sh
docker run --rm --user "$(id -u):$(id -g)" \
    fortran-ci:ubuntu26.04 with-oneapi ifx --version
```

For project runners, use `with-oneapi bash /path/to/run-tests.sh ...`. Select
`ifx` as the Fortran compiler and `gcc-15` as the C compiler in CMake. GNU jobs
can also use `with-oneapi` to discover MKL. The default command remains `bash`;
Intel's environment is initialized only when requested.

### Project builds

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
- Build parallelism defaults to 4; OpenMP threads default to 2 and MKL threads
  default to 1. Override with `-e`.
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
