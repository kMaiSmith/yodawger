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
	local IFS=":"
	local _path=""

	for subenv in ${1}; do
		_path+="env/${subenv}/"
	done
	echo "${_path}"
}
export -f env_path

env::get_default() {
	local default_env_file="${SYSTEM_CONF}/default_env"

	[ -f "${default_env_file}" ] || \
		echo "default" > "${default_env_file}"

	cat "${default_env_file}"
}

env::init() {
	local name="${1}"

	local _env_dir _env_conf _env_user="${name}_env"
	_env_dir="${SYSTEM_ROOT}/$(env_path "${name}")"
	_env_conf="${ENV_ROOT}/conf"
	id "${name}_env" &>/dev/null || \
		adduser --system --no-create-home \
			--group --home "${_env_dir}" "${name}_env"

	mkdir -p "${_env_dir}" "${_env_conf}"
	chown -R "${_env_user}:${_env_user}" "${_env_dir}"
}

env::daemon() {
	local name="${1}"

	local _runtime_dir="${SYSTEM_ROOT}/$(env_path "${name}")/.docker/run"
	mkdir -p "${_runtime_dir}"
	chown -R "${name}_env:${name}_env" "${_runtime_dir}"
	systemctl start "user@$(id -u "${name}_env")"

	sudo -u "${name}_env" \
		XDG_RUNTIME_DIR="${_runtime_dir}" \
		dockerd-rootless.sh

	systemctl stop "user@$(id -u "${name}_env")"
	rm -rf "${_runtime_dir}"
}
