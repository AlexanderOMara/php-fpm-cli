#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

run sh -c 'cat > /tmp/manual-post.php' << 'EOF'
<?php
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']}"
	. " {$_POST['foo']} {$_POST['baz']}";
EOF
expected='POST /tmp/manual-post.php bar qux';

status=0
output="$(run php-fpm-cli -c "${listen}" \
	-p 'SCRIPT_FILENAME=/tmp/manual-post.php' \
	-p 'REQUEST_METHOD=POST' \
	-p 'CONTENT_TYPE=application/x-www-form-urlencoded' \
	-p 'CONTENT_LENGTH=15' \
	-b 'foo=bar&baz=qux'
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
