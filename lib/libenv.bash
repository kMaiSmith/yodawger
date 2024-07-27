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

env_path() {
	echo "env/${1}"
}
export -f env_path

env::get_default() {
	local default_env_file="${SYSTEM_CONF}/default_env"

	[ -f "${default_env_file}" ] || \
		echo "default" > "${default_env_file}"

	cat "${default_env_file}"
}
export -f env::get_default

env::get_user() {
	local env="${1:-"${SYSTEM_ENV}"}"

	echo "${env}_env"
}
export -f env::get_user

env::get_home() {
	local env="${1:-"${SYSTEM_ENV}"}"

	echo "${SYSTEM_ROOT}/env/${env}"
}
export -f env::get_home

