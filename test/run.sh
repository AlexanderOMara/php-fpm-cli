#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

__self="${BASH_SOURCE[0]}"
__dir="$(cd "$(dirname "${__self}")" > /dev/null && pwd)"
__file="${__dir}/$(basename "${__self}")"

if [[ "$#" -ne 2 ]]; then
	echo "$(basename "$0") <image> <port>"
	exit 1
fi

image="$1"
port="$2"

source="$(dirname "${__dir}")/php-fpm-cli"
destination='/usr/local/bin/php-fpm-cli'
result=0

if [[ "${port}" != '0' ]]; then
	conf="${__dir}/cfg/port.conf"
	protocol='tcp'
else
	conf="${__dir}/cfg/unix.conf"
	protocol='unix'
fi

export service='php-fpm-cli'
export listen="$(grep 'listen = .*' "${conf}" | sed 's/.*= *//')"
export protocol
confd='/usr/local/etc/php-fpm.d/zzzz.conf'

run() {
	docker exec -i "${service}" "$@"
}
export -f run

echo "Starting: ${service}:${image}"
echo "Listening: ${listen}"
coproc docker run --rm \
	--name "${service}" \
	--mount "type=bind,source=${source},destination=${destination},readonly" \
	--mount "type=bind,source=${conf},destination=${confd}" \
	"${image}" 2>&1
trap "docker stop '"${service}"' > /dev/null || true" SIGINT SIGTERM EXIT
server_stdout="${COPROC[0]}"

started=0
while read -r -u "${server_stdout}" line; do
	printf '%s\n' "${line}"
	if [[ "${line}" == *'ready to handle connections'* ]]; then
		started=1
		break
	fi
done
if [[ "${started}" == '0' ]]; then
	echo "ERROR: Failed to start server"
	result=1
else
	for spec in "${__dir}"/spec/*.sh; do
		echo '----------------------------------------------------------------'
		echo "SPEC: $(basename "${spec}")"
		echo '----------------------------------------------------------------'
		status=0
		"${spec}" || status=$?
		if [[ "${status}" == 0 ]]; then
			echo "PASS"
		else
			echo "FAIL: ${status}"
			result=1
		fi
	done
fi

docker stop "${service}" > /dev/null || true
trap - SIGINT SIGTERM EXIT
exit "${result}"
