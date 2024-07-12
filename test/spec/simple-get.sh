#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

run sh -c 'cat > /tmp/simple-get.php' << 'EOF'
<?php
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']} ", PHP_SAPI;
EOF
expected='GET /tmp/simple-get.php fpm-fcgi';

status=0
output="$(run php-fpm-cli -c "${listen}" '/tmp/simple-get.php')" || status=$?
if [[ "${status}" != 0 ]]; then
	echo "ERROR: Expected status 0, got: ${status}"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != "${expected}" ]]; then
	echo "ERROR: Unexpected output"
	echo "EXPECT: ${expected}"
	echo "ACTUAL: ${output}"
	result=1
fi

exit "${result}"
