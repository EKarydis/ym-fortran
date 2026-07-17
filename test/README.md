# Tests for `error` and `strings`

The tests are intentionally split into two executables:

- `test_strings.f90` checks the return value of `lower_case`.
- `test_error.f90` exposes separate modes for warning and terminating paths.
- `run_error_tests.sh` launches each error test in a separate process and checks
  its exit status and diagnostic output.

Example with GNU Fortran, assuming the project modules have already been built:

```sh
gfortran -Ibuild/gfortran/mod -Jbuild/gfortran/mod \
  test/test_strings.f90 build/gfortran/obj/ym_strings.o \
  -o build/gfortran/test/test_strings

gfortran -Ibuild/gfortran/mod -Jbuild/gfortran/mod \
  test/test_error.f90 \
  build/gfortran/obj/ym_error.o build/gfortran/obj/ym_kinds.o \
  -o build/gfortran/test/test_error

build/gfortran/test/test_strings
./test/run_error_tests.sh build/gfortran/test/test_error
```

`run_error_tests.sh` checks diagnostic content rather than exact whitespace, so
minor formatting changes in `ym_error` do not make the tests unnecessarily
brittle.
