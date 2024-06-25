#!/usr/bin/env bash

set -ueo pipefail

_docker_compose() {
	DOCKER_HOST="unix://${SERVICES_ROOT}/$(_env_path "${SERVICE_ENV}")/.docker/run/docker.sock" \
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
export -f _get_free_port

_get_port() {
	local _name="${1:-"default"}"
	local _port_file="${SERVICE_ENV_CONF}/port.${_name}"

	[ -f "${_port_file}" ] || \
		_get_free_port > "${_port_file}"

	cat "${_port_file}"
}
export -f _get_port

_generate_password() {
	date +%s | sha256sum | base64 | head -c 32
}
export -f _generate_password

_get_password() {
	local _name="${1:-"default"}"
	local _password_file="${SERVICE_ENV_CONF}/password.${_name}"

	[ -f "${_password_file}" ] || \
		_generate_password > "${_password_file}"

	chmod 600 "${_password_file}"
	cat "${_password_file}"
}
export -f _get_password

log() {
	local _level="${1}"
	local _message="${2}"

	{ >&9; } 2> /dev/null || exec 9>&2

	echo "[${_level}] ${_message}" >&9
}
export -f log

error() {
	local _message="${2-}"

	if [ -n "${_message-}" ]; then
		log ERROR "${_message}"
	fi

	exit 1
}
export -f error

_env_path() {
	local IFS=":"
	local _env_path=""

	for subenv in ${1}; do
		_env_path+="env/${subenv}/"
	done
	echo "${_env_path}"
}
export -f _env_path
