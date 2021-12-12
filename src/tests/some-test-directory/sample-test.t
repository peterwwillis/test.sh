# vim: syntax=sh

[ "${DEBUG:-0}" = "1" ] && set -x
set -u

_t_sample_test_1 () {
    cd "$tmpdir"
    echo "This is sample test 1"
    pwd
    return 0
}

_t_sample_test_2 () {
    cd "$tmpdir"
    echo "This is sample test 2"
    pwd
    return 0
}

ext_tests="sample_test_1 sample_test_2"
