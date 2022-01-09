#!/usr/bin/env sh
# vim: syntax=sh
# shellcheck disable=SC2164

[ "${DEBUG:-0}" = "1" ] && set -x
set -u

_t_sample_test_1 () {
    cd "$testtmpdir"
    echo "This is sample test 1"
    pwd
    return 0
}

_t_echo_testbasename () {
    echo "Test name: $testbasename"
    return 0
}

ext_tests="sample_test_1 echo_testbasename"
