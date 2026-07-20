# ym-fortran

`ym-fortran` is a modern Fortran (2018+) codebase for numerical simulations of pure
Yang–Mills lattice gauge theories. 

## Current status

| Module | Source file | Status | Purpose |
|---|---|---:|---|
| `parameters` | `parameters.F90` | Ready | Floating-point precision, I/O units, and common numerical constants |
| `error` | `error.f90` | Ready | Common error-reporting facilities |
| `strings` | `strings.f90` | Ready | Common character and string utilities |
| `lattice_mod` | `lattice.f90` | Ready | Lattice geometry handling
| `gauge_mod` | In development | groups, gauge groups and gauge fields |



Currently implemented and tested modules include:

- numerical and compiler parameters;
- error handling;
- string utilities;
- lattice geometry and indexing.


The current tests pass with:

- GNU Fortran 13.3.0 (`gfortran`);
- Intel Fortran Compiler 2026.1.0 (`ifx`);
- NVIDIA Fortran Compiler 26.1-0 (`nvfortran`).

on `Ubuntu 24.04.4 LTS` kernel: `6.8.0-134-generic` and 
on `macOS 26.5.2` kernel: `Darwin 25.5.0`

## Building

The project is built with GNU Make and supports separate build directories 
for different compilers, build types, and floating-point precisions.
The building system is tested with `GNU Make 4.3`

### Requirements

You need:

* GNU Make
* A Fortran 2018 compiler
* An existing [FortranMatrix](https://github.com/KNAnagnostop/FortranMatrix.git) installation 
* `LIBMATRIX_ROOT` set to the FortranMatrix installation prefix

The codebase has been tested with:

* `gfortran v13.3.0`
* `gfortran v16.1.0`
* `ifx v2026.1.0`
* `nvfortran v26.1-0`

### Default build

To build the project with the default configuration, run:

```bash
make
```

The default configuration uses:

```text
Compiler:   gfortran
Build type: debug
Precision:  double
```

Build files are written to:

```text
build/<compiler>/<build-type>/<precision>/
```

For example:

```text
build/gfortran/debug/double/
├── mod/
├── obj/
└── test/
```


### Selecting a compiler

Use the `COMPILER` variable to select a compiler:

```bash
make COMPILER=gfortran
make COMPILER=ifx
make COMPILER=nvfortran
```

Each compiler uses an independent build directory, so builds from different compilers can coexist.

### Selecting the precision

The floating-point precision is selected with the `PRECISION` variable:

```bash
make PRECISION=single
make PRECISION=double
```

The default precision is `double`.

Compiler preprocessing is used to configure the precision defined in `parameters.F90`.

### Selecting the build type

Use the `BUILD` variable to select the build configuration:

```bash
make BUILD=debug
make BUILD=release
```

Debug builds enable additional warnings and runtime checks, while release builds enable compiler optimization.

### Running the tests

To build and run the complete test suite:

```bash
make test
```

Individual tests can also be built and run separately:

```bash
make test-parameters
make test-error
make test-strings
make test-lattice
```

To test both supported floating-point precisions:

```bash
make test-precisions
```

To run the test suite with every configured compiler:

```bash
make test-compilers
```

This requires all supported compilers to be installed and available in `PATH`.

A specific compiler and precision can also be tested directly:

```bash
make COMPILER=ifx PRECISION=double test
make COMPILER=nvfortran PRECISION=single test
```

### Build information

To display the active build configuration:

```bash
make info
```

To display the available Make targets:

```bash
make help
```

### Cleaning

To remove the active build configuration:

```bash
make clean
```

To remove every build associated with the selected compiler:

```bash
make COMPILER=gfortran clean-compiler
```

To remove the complete build directory:

```bash
make distclean
```

