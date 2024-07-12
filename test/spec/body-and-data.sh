#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

status=0
output="$(run php-fpm-cli -c 'DUMMY' -b 'B' --data='D' 2>&1)" || status=$?
if [[ "${status}" != 1 ]]; then
	echo "ERROR: Expected status 1, got: ${status}"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != "ERROR: Invalid options: -b and -d" ]]; then
	echo "ERROR: Unexpected output"
	echo "OUTPUT: ${output}"
	result=1
fi

status=0
output="$(run php-fpm-cli -c 'DUMMY' --body 'B' -d='D' 2>&1)" || status=$?
if [[ "${status}" != 1 ]]; then
	echo "ERROR: Expected status 1, got: ${status}"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != "ERROR: Invalid options: -b and -d" ]]; then
	echo "ERROR: Unexpected output"
	echo "OUTPUT: ${output}"
	result=1
fi

exit "${result}"
