#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

run sh -c 'cat > /tmp/headers.php' << 'EOF'
<?php
http_response_code(500);
header("X-Foo: {$_SERVER['HTTP_X_BAZ']}");

echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']}";
EOF

status=0
output="$(run php-fpm-cli -c "${listen}" -p 'HTTP_X_BAZ=Bar' -i '/tmp/headers.php')" || status=$?
if [[ "${status}" != 1 ]]; then
	echo "ERROR: Expected status 1, got: ${status}"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != *'GET /tmp/headers.php' ]]; then
	echo "ERROR: Unexpected output body"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != *'Status: 500 Internal Server Error'* ]]; then
	echo "ERROR: Unexpected output status"
	echo "OUTPUT: ${output}"
	result=1
fi
if [[ "${output}" != *'X-Foo: Bar'* ]]; then
	echo "ERROR: Unexpected output header"
	echo "OUTPUT: ${output}"
	result=1
fi

exit "${result}"
