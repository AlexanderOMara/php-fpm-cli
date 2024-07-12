#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

run sh -c 'cat > /tmp/simple-post.php' << 'EOF'
<?php
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']}"
	. " {$_POST['foo']} {$_POST['baz']}";
EOF
expected='POST /tmp/simple-post.php bar qux';

status=0
output="$(run php-fpm-cli -c "${listen}" \
	-p 'CONTENT_TYPE=application/x-www-form-urlencoded' \
	-b 'foo=bar&baz=qux' \
	'/tmp/simple-post.php')" || status=$?
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
