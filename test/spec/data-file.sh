#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

result=0

data='DATA DATA DATA DATA DATA DATA DATA DATA'
data="${data} ${data} ${data} ${data} ${data} ${data} ${data} ${data}"
data="${data} ${data} ${data} ${data} ${data} ${data} ${data} ${data}"

for i in {1..100}; do
	printf "%s %s\n" "${i}" "${data}"
done | run sh -c 'cat > /tmp/data-file.txt'

run sh -c 'cat > /tmp/data-file.php' << 'EOF'
<?php
$body = file_get_contents('php://input');
$len = strlen($body);
$md5 = md5($body);
echo "{$_SERVER['REQUEST_METHOD']} {$_SERVER['SCRIPT_FILENAME']} $len $md5";
EOF
expected='POST /tmp/data-file.php 256292 fd119a115734b019df0db8273b50baa9';

status=0
output="$(run php-fpm-cli -c "${listen}" \
	-d '/tmp/data-file.txt' \
	'/tmp/data-file.php'
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
