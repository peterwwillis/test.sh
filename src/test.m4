#!/usr/bin/env sh
# test.sh - minimal script testing 'framework'
# Copyright (c) 2020-2021  Peter Willis
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

[ "${DEBUG:-0}" = "1" ] && set -x
TESTSH_VERSION=0.2
set -u

### How to use test.sh:
### 
###  1. Create some shell scripts in tests/ directory, filename ending with '.t'
###  2. Define some functions ('_t_NAME') in that shell script
###     a. Put the space-separated NAMEs in global variable $ext_tests
###     b. Register test pass/fail with 'return 0' / 'return 1'
###  3. Run `./test.sh tests/*.t`

PWD="${PWD:-$(pwd)}"
TESTSH_SRCDIR="${TESTSH_SRCDIR:-$PWD}"
TESTSH_SRCDIR="$(cd "$TESTSH_SRCDIR" && pwd -P)"
TESTSH_LOGGING="${TESTSH_LOGGING:-0}"
TESTSH_ENVRC="${TESTSH_ENVRC:-$TESTSH_SRCDIR/.testshrc}"
TESTSH_TESTEXT="${TESTSH_TESTEXT:-.t}"

_main () {
    _fail=0 _pass=0 _failedtests=""
    testshpwd="$(pwd)"

    for i in "$@" ; do

        cd "$testshpwd" || { echo "$0: Error: could not cd '$testshpwd'" && exit 1 ; }

        # The following variables should be used by the tests
        testbasename="$(basename "$i" "$TESTSH_TESTEXT")"  ### So you don't need ${BASH_SOURCE[0]}
        testtmpdir="$(mktemp -d)"            ### Copy your test files into here

        # Terrible, horrible, no good kludge to add a path to $i
        [ "$(expr "$i" : '.*/')" = 0 ] && i="$(cd "$(dirname "$i")" && pwd -P)/$i"

        . "$i" # load the test script into this shell

        # Now we should have a variable $ext_tests set by the test script.
        # The value is a string of space-separated names of '_t_SOMETHING' functions to run.
        __fail=0 __pass=0
        for t in $ext_tests ; do
            cd "$testshpwd" || { echo "$0: Error: could not cd '$testshpwd'" && exit 1 ; }
            echo "$0: Running test '$t'"

            command -v _testsh_pre_test >/dev/null 2>&1 && _testsh_pre_test "$t"
            if    [ "${TESTSH_LOGGING:-0}" = "1" ] ; then
                testshlogfile="$testshpwd/test_${testbasename}_${t}.log"
                echo "$0: Logging to file '$testshlogfile'"
                "_t_$t" > "$testshlogfile" 2>&1 ; ret=$?
            else
                "_t_$t" ; ret=$?
            fi
            command -v _testsh_post_test >/dev/null 2>&1 && _testsh_post_test "$t"

            if [ $ret -ne 0 ] ; then
                echo "$0: $testbasename: Test $t failed"
                __fail=$((__fail+1))
                _failedtests="$_failedtests $testbasename:$t"
            else
                echo "$0: $testbasename: Test $t succeeded"
                __pass=$((__pass+1))
                if [ "${TESTSH_LOGGING:-0}" = "1" ] && [ ! "${TESTSH_LOGGING_KEEP_SUCCESS:-0}" = "1" ] ; then
                    rm -f "$testshlogfile"
                fi
            fi
        done

        rm -rf "$testtmpdir"
        [ $__fail -gt 0 ] && echo "$0: $testbasename: Failed $__fail tests" && _fail="$((_fail+__fail))"
        _pass=$((_pass+__pass))

    done
}

# Load config and export all variables
if [ -n "${TESTSH_ENVRC:-}" ] && [ -r "${TESTSH_ENVRC:-}" ] ; then
    set -a ; . "$TESTSH_ENVRC" ; set +a
fi

_main "$@"
echo "$0: Passed $_pass tests"
if [ $_fail -gt 0 ] ; then
    echo "$0: Failed $_fail tests ($_failedtests)"
    [ "${TESTSH_LOGGING:-0}" = "1" ] && echo "$0: Check log files for more details."
    exit 1
fi

# vim: syntax=sh
