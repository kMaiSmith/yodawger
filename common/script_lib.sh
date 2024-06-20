#!/usr/bin/env bash

set -ueo pipefail

_docker_compose() {
	docker compose \
		-f "${SERVICE_ROOT}/conf/docker-compose.yaml" \
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

_get_port() {
	local _name="${1:-"default"}"
	local _port_file="${SERVICE_ENV_CONF}/port.${_name}"

	[ -f "${_port_file}" ] || \
		_get_free_port > "${_port_file}"

	cat "${_port_file}"
}

_generate_password() {
	date +%s | sha256sum | base64 | head -c 32
}

_get_password() {
	local _name="${1:-"default"}"
	local _password_file="${SERVICE_ENV_CONF}/password.${_name}"

	[ -f "${_password_file}" ] || \
		_generate_password > "${_password_file}"

	chmod 600 "${_password_file}"
	cat "${_password_file}"
}

