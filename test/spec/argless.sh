#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

status=0
output="$(run php-fpm-cli 2>&1)" || status=$?
if [[ "${status}" != 1 ]]; then
	echo "ERROR: Expected status 1, got: ${status}"
	result=1
fi
if [[ "${output}" != "Usage: php-fpm-cli "* ]]; then
	echo 'ERROR: Expected help'
	echo "OUTPUT: ${output_short}"
	result=1
fi

exit "${result}"
