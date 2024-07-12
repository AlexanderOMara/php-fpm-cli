#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

run sh -c 'cat > /tmp/manual-get.php' << 'EOF'
<?php
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']} {$_GET['foo']} {$_GET['baz']}";
EOF
expected='GET /tmp/manual-get.php bar qux';

status=0
output="$(run php-fpm-cli -c "${listen}" \
	-p 'SCRIPT_FILENAME=/tmp/manual-get.php' \
	-p 'QUERY_STRING=foo=bar&baz=qux' \
	-p 'REQUEST_METHOD=GET' \
)" || status=$?
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
