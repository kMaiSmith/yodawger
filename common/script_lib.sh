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

