#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

run sh -c 'cat > /tmp/simple-put.php' << 'EOF'
<?php
$body = file_get_contents('php://input');
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']} {$body}";
EOF
expected='PUT /tmp/simple-put.php THE_BODY';

status=0
output="$(run php-fpm-cli -c "${listen}" \
	-p 'REQUEST_METHOD=PUT' \
	--body='THE_BODY' \
	'/tmp/simple-put.php')" || status=$?
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
