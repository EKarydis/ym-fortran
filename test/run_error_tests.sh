#!/usr/bin/env sh
set -u

exe=${1:-./test_error}
work_dir=${TMPDIR:-/tmp}/ym_error_tests.$$
failures=0

mkdir -p "$work_dir" || exit 1
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

pass() {
    printf '%s\n' "[PASS] $1"
}

fail() {
    printf '%s\n' "[FAIL] $1"
    failures=$((failures + 1))
}

contains_text() {
    file=$1
    text=$2
    grep -F "$text" "$file" >/dev/null 2>&1
}

# warning must return success and write a useful diagnostic to stderr.
if "$exe" warning >"$work_dir/warning.out" 2>"$work_dir/warning.err"; then
    if contains_text "$work_dir/warning.err" 'WARNING' \
       && contains_text "$work_dir/warning.err" 'test_warning' \
       && contains_text "$work_dir/warning.err" 'expected warning message'; then
        pass 'warning'
    else
        fail 'warning output'
        cat "$work_dir/warning.err"
    fi
else
    fail 'warning exit status'
fi

# A true condition must return normally and print no error diagnostic.
if "$exe" condition_pass >"$work_dir/condition_pass.out" \
                          2>"$work_dir/condition_pass.err"; then
    if [ ! -s "$work_dir/condition_pass.err" ]; then
        pass 'condition_error(.true.)'
    else
        fail 'condition_error(.true.) wrote to stderr'
        cat "$work_dir/condition_pass.err"
    fi
else
    fail 'condition_error(.true.) exit status'
fi

# fatal_error must terminate with a nonzero status and print its diagnostic.
if "$exe" fatal >"$work_dir/fatal.out" 2>"$work_dir/fatal.err"; then
    fail 'fatal_error returned normally'
else
    if contains_text "$work_dir/fatal.err" 'ERROR' \
       && contains_text "$work_dir/fatal.err" 'test_fatal' \
       && contains_text "$work_dir/fatal.err" 'expected fatal message'; then
        pass 'fatal_error'
    else
        fail 'fatal_error output'
        cat "$work_dir/fatal.err"
    fi
fi

# A false condition must terminate through fatal_error.
if "$exe" condition_fail >"$work_dir/condition_fail.out" \
                          2>"$work_dir/condition_fail.err"; then
    fail 'condition_error(.false.) returned normally'
else
    if contains_text "$work_dir/condition_fail.err" 'ERROR' \
       && contains_text "$work_dir/condition_fail.err" 'test_condition_fail' \
       && contains_text "$work_dir/condition_fail.err" \
                        'expected condition failure message'; then
        pass 'condition_error(.false.)'
    else
        fail 'condition_error(.false.) output'
        cat "$work_dir/condition_fail.err"
    fi
fi

if [ "$failures" -ne 0 ]; then
    printf '%s\n' "[FAIL] error: $failures test(s) failed"
    exit 1
fi

printf '%s\n' '[PASS] error'
