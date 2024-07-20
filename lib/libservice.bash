#!/usr/bin/env bash
#
# Yodawger
# Copyright (C) 2024  Kyle Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -ueo pipefail
export SHELLOPTS

include "<system/network>"

service::discover() {
	local _name="${1}"

	export SERVICE_NAME SERVICE_ROOT SERVICE_ENV SERVICE_ENV_ROOT \
		ENV_SERVICE_ROOT ENV_ROOT SERVICE_CONF SERVICE_NETWORK
	SERVICE_NAME="${_name}"
	SERVICE_ROOT="$(find "${SYSTEM_ROOT}/services" \
			-maxdepth 1 -mindepth 1 \
			-name "${SERVICE_NAME}")"
	if [ -f "${SERVICE_ROOT}/force-env" ]; then
		SERVICE_ENV="$(cat "${SERVICE_ROOT}/force-env" | xargs -r)"
	else
		SERVICE_ENV="${SYSTEM_ENV}"
	fi
	yo env exists "${SERVICE_ENV}" || \
		error "Yodawg environment ${SERVICE_ENV} does not exist"
	mkdir -p "${SERVICE_ROOT}/env"
	SERVICE_ENV_ROOT="${SERVICE_ROOT}/$(env_path "${SERVICE_ENV}")"
	ENV_ROOT="${SYSTEM_ROOT}/$(env_path "${SERVICE_ENV}")"
	ENV_SERVICE_ROOT="${ENV_ROOT}/services/${SERVICE_NAME}"
	SERVICE_CONF="${SERVICE_ROOT}/conf"
	SERVICE_NETWORK="${SERVICE_ENV}_${SERVICE_NAME}"
}

service::init() {
	export SERVICE_DATA SERVICE_ENV_CONF SERVICE_LOG SERVICE_CACHE SERVICES_IP SERVICE_SOCKET

	[ "$(readlink -f "${SERVICE_ENV_ROOT}")" = "${ENV_ROOT}" ] || \
		service::init_dir

	SERVICE_DATA="${SERVICE_ENV_ROOT}/data"
	SERVICE_ENV_CONF="${SERVICE_ENV_ROOT}/conf"
	SERVICE_LOG="${SERVICE_ENV_ROOT}/log"
	SERVICE_CACHE="${SERVICE_ENV_ROOT}/cache"
	SERVICE_SOCKET="${SERVICE_ENV_ROOT}/socket"
	SERVICES_IP="$(hostname -I | awk '{print $1}')"

	mkdir -p "${SERVICE_DATA}" "${SERVICE_ENV_CONF}" \
		"${SERVICE_LOG}" "${SERVICE_CACHE}" "${SERVICE_SOCKET}"

	service::init_configs
}

service::init_dir() {
	if [ -d "${SERVICE_ENV_ROOT}" ] && [ ! -d "${ENV_SERVICE_ROOT}" ]; then
		# Migrate data stored in the service dir to the env dirs
		mkdir -p "$(dirname "${ENV_SERVICE_ROOT}")"
		mv "${SERVICE_ENV_ROOT}" "${ENV_SERVICE_ROOT}"
	elif [ -L "${SERVICE_ENV_ROOT}" ] && [ "$(readlink -f "${SERVICE_ENV_ROOT}")" != "${ENV_SERVICE_ROOT}" ]; then
		error "directory aleady exists for service ${SERVICE_NAME} in env ${SERVICE_ENV} (${ENV_SERVICE_ROOT})"
	else
		mkdir -p "${ENV_SERVICE_ROOT}"
	fi

	[ "${ENV_SERVICE_ROOT}" = "${SERVICE_ENV_ROOT}" ] || \
		ln -sfT "${ENV_SERVICE_ROOT}" "${SERVICE_ENV_ROOT}"
}

service::init_configs() {
	set -a
	if [ -f "${SYSTEM_ROOT}/$(env_path "${SERVICE_ENV}")/config.sh" ]; then
		source "${SYSTEM_ROOT}/$(env_path "${SERVICE_ENV}")config.sh"
	fi
	if [ -f "${SERVICE_ROOT}/config.sh" ]; then
		source "${SERVICE_ROOT}/config.sh"
	fi
	if [ -f "${SERVICE_ENV_ROOT}/config.sh" ]; then
		source "${SERVICE_ENV_ROOT}/config.sh"
	fi
	set +a
}

service::list() {
	find "${SYSTEM_ROOT}/services" \
		-maxdepth 1 -mindepth 1 -type d| \
		xargs -rL1 basename
	exit
}

service::get_password() {
	local _name="${1:-"default"}"
	local _password_file="${SERVICE_ENV_CONF}/password.${_name}"

	[ -f "${_password_file}" ] || \
		date +%s | sha256sum | base64 | head -c 32 > "${_password_file}"

	chmod 600 "${_password_file}"
	cat "${_password_file}"
}
export -f service::get_password

service::get_port() {
	local _name="${1:-"default"}"
	local _port_file="${SERVICE_ENV_CONF}/port.${_name}"

	[ -f "${_port_file}" ] || \
		python3 <<PYTHON > "${_port_file}"
# Yo Dawg, i heard you liked code smells, so I mixed some python with your bash
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 0))
addr = s.getsockname()
print(addr[1])
s.close()
PYTHON

	cat "${_port_file}"
}
export -f service::get_port

service::add() {
	local _name="${1}"
	local _git_url="${2}"

	if [ -d "${SYSTEM_ROOT}/services/${_name}" ]; then
		error "Service ${_name} already exists"
	fi

	mkdir -p "${SYSTEM_ROOT}/services"
	git clone "${_git_url}" "${SYSTEM_ROOT}/services/${_name}"
}
export -f service::add

service::update() {
	local _name="${1}"

	git -C "${SYSTEM_ROOT}/services/${_name}" pull
}
export -f service::update

service::up() {
	include "<docker>"

	docker::network::create

	docker::compose up -d
}
export -f service::up

service::down() {
	include "<docker>"

	docker::compose down

	docker::network::rm
}
export -f service::down

