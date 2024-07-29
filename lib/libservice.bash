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

service::get_root() {
	local name="${1}"
}
export -f server::get_root

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

	if [ -x "${SERVICE_ROOT}/bin/pre-up" ]; then
		rootlesskit -- "${SERVICE_ROOT}/bin/pre-up"
	fi
	docker::compose up -d
	if [ -x "${SERVICE_ROOT}/bin/post-up" ]; then
		rootlesskit -- "${SERVICE_ROOT}/bin/post-up"
	fi
}
export -f service::up

service::down() {
	include "<docker>"

	if [ -x "${SERVICE_ROOT}/bin/pre-down" ]; then
		rootlesskit -- "${SERVICE_ROOT}/bin/pre-down"
	fi

	docker::compose down

	if [ -x "${SERVICE_ROOT}/bin/post-down" ]; then
		rootlesskit -- "${SERVICE_ROOT}/bin/post-down"
	fi
}
export -f service::down
