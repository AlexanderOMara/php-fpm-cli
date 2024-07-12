#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

output_short="$(run php-fpm-cli -v)"
output_long="$(run php-fpm-cli --version)"
if [[ "${output_short}" != "${output_long}" ]]; then
	echo 'ERROR: Version mismatch'
	echo "OUTPUT A: ${output_short}"
	echo "OUTPUT B: ${output_long}"
	result=1
fi

status=0
grep '^\d*\.\d*\.\d*' > /dev/null <<< "${output_short}" || status=$?
if [[ "${status}" != 0 ]]; then
	echo 'ERROR: Version invalid'
	echo "OUTPUT: ${output_short}"
	result=1
fi

exit "${result}"
