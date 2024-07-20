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

	if [ "${1}" != "host" ]; then
		for subenv in ${1}; do
			_path+="env/${subenv}/"
		done
		echo "${_path%/}"
	fi
}
export -f env_path

env::get_default() {
	local default_env_file="${SYSTEM_CONF}/default_env"

	[ -f "${default_env_file}" ] || \
		echo "default" > "${default_env_file}"

	cat "${default_env_file}"
}
export -f env::get_default

env::init() {
	local name="${1}"

	local _env_dir _env_conf _env_user="${name}_env"
	_env_dir="${SYSTEM_ROOT}/$(env_path "${name}")"
	_env_conf="${_env_dir}/conf"
	id "${name}_env" &>/dev/null || \
		useradd --create-home --user-group --home-dir "${_env_dir}" "${name}_env"

	mkdir -p "${_env_dir}" "${_env_conf}"
	sudo -u "${_env_user}" test -O "${_env_dir}" || \
		chown -R "${_env_user}:${_env_user}" "${_env_dir}"
	loginctl enable-linger "${_env_user}"

	usermod -aG env_global "${_env_user}"

	local _config_dir="${_env_dir}/.config"

	mkdir -p "${_config_dir}/docker"
	chown -R "${_env_user}:${_env_user}" "${_config_dir}"
	cat <<CONFIG | sudo -u "${_env_user}" tee "${_config_dir}/docker/daemon.json" >/dev/null 
{
	"storage-driver": "fuse-overlayfs"
}
CONFIG

	machinectl shell "${_env_user}@" /usr/bin/dockerd-rootless-setuptool.sh install

	machinectl shell "${_env_user}@" /usr/bin/systemctl --user enable docker
	machinectl shell "${_env_user}@" /usr/bin/systemctl --user start docker
}
export -f env::init

