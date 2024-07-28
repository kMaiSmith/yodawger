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

service::get_password() {
	local _name="${1:-"default"}"
	local _password_file="${COMPONENT_CONF}/password.${_name}"

	[ -f "${_password_file}" ] || \
		date +%s | sha256sum | base64 | head -c 32 > "${_password_file}"

	chmod 600 "${_password_file}"
	cat "${_password_file}"
}
export -f service::get_password

service::get_port() {
	local _name="${1:-"default"}"
	local _port_file="${COMPONENT_CONF}/port.${_name}"

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
