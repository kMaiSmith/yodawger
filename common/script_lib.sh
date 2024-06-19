#!/usr/bin/env bash

set -ueo pipefail

_docker_compose() {
	docker compose \
		-f "${SERVICE_DIR}/conf/docker-compose.yaml" \
		-p "${SERVICE_NAME}" \
		"${@}"
}
export -f _docker_compose

_get_free_port() {
	python3 <<PYTHON
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 0))
addr = s.getsockname()
print(addr[1])
s.close()
PYTHON
}

_get_active_port() {
	[ -f "${SERVICE_DIR}/conf/port" ] || \
		_get_free_port > "${SERVICE_DIR}/conf/port"

	cat "${SERVICE_DIR}/conf/port"
}

export SERVICE_DIR SERVICE_PORT SERVICE_NAME SERVICE_DATA SERVICE_CACHE ENVIRONMENT
SERVICES_ROOT="/Applications"
SERVICE_DIR="$(find "${SERVICES_ROOT}" \
		-maxdepth 1 -mindepth 1 \
		-iname "${SERVICE_NAME}.service" \
		-type d)"
SERVICE_DATA="${SERVICE_DIR}/data"
SERVICE_CACHE="${SERVICE_DIR}/.service"
ENVIRONMENT="default"
mkdir -p "${SERVICE_CACHE}"

set -a
source "${SERVICE_DIR}/env/${ENVIRONMENT}"

SERVICE_PORT="$(_get_active_port || _get_free_port)"
