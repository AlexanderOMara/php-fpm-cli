#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

status=0
output="$(run php-fpm-cli -c 'DUMMY' /tmp/invalid-f.php 2>&1)" || status=$?
if [[ "${status}" != 1 ]]; then
	echo "ERROR: Expected status 1, got: ${status}"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != "ERROR: Invalid script file: /tmp/invalid-f.php" ]]; then
	echo "ERROR: Unexpected output"
	echo "OUTPUT: ${output}"
	result=1
fi

run mkdir /tmp/invalid-d.php

status=0
output="$(run php-fpm-cli -c 'DUMMY' /tmp/invalid-d.php 2>&1)" || status=$?
if [[ "${status}" != 1 ]]; then
	echo "ERROR: Expected status 1, got: ${status}"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != "ERROR: Invalid script file: /tmp/invalid-d.php" ]]; then
	echo "ERROR: Unexpected output"
	echo "OUTPUT: ${output}"
	result=1
fi

exit "${result}"
