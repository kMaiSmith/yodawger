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

export SYSTEM_ROOT="${SYSTEM_ROOT:-"/yodawg"}"
export PATH="${HOME}/.local/bin:${SYSTEM_ROOT}/bin:${PATH}"

log() {
	local _level="${1}"
	local _message="${2}"

	{ >&9; } 2> /dev/null || exec 9>&2

	echo "[${_level}] ${_message}" >&9
}
export -f log

error() {
	local _message="${1-}"

	if [ -n "${_message-}" ]; then
		log ERROR "${_message}"
	fi

	exit 1
}
export -f error

include() {
	local _path
	case "${1}" in
		\<*\>)
			local _lib _lib_dir _lib_file
			_lib="$(sed -r 's/<(.*)>/\1/' <<< "${1}")"
			_lib_dir="$(dirname "${_lib}")"
			_lib_file="lib$(basename "${_lib}").bash"
			if [ "${USER}" = "root" ]; then
				_path="${SYSTEM_ROOT}/lib/${_lib_dir}/${_lib_file}"
			else
				_path="${HOME}/.local/lib/${_lib_dir}/${_lib_file}"
			fi
			;;
		*)
			_path="$(dirname "${BASH_SOURCE[0]}")/${1}"
			;;
			
	esac
	if [ -f "${_path}" ]; then
		source "${_path}"
	else
		error "Could not find library ${1}"
	fi
}
export -f include

