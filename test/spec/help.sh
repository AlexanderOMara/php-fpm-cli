#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

output_short="$(run php-fpm-cli -h)"
output_long="$(run php-fpm-cli --help)"
if [[ "${output_short}" != "${output_long}" ]]; then
	echo 'ERROR: Help mismatch'
	echo "OUTPUT A: ${output_short}"
	echo "OUTPUT B: ${output_long}"
	result=1
fi

status=0
if [[ "${output_short}" != "Usage: php-fpm-cli "* ]]; then
	echo 'ERROR: Help invalid'
	echo "OUTPUT: ${output_short}"
	result=1
fi

exit "${result}"
