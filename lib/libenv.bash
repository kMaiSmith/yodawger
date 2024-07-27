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

env::init() {
	local name="${1}"

	local env_user="$(env::get_user "${name}")"
	local env_home="$(env::get_home "${name}")"

	env::init::user "${env_user}" "${env_home}"
	env::init::rootless_docker "${env_user}" "${env_home}"
	env::init::pipeline_supervisor "${env_user}" "${env_home}"
}
export -f env::init

env::init::user() {
	local env_user="${1}"
	local env_home="${2}"

	log INFO "Ensuring ${env_user} user is present and configured"

	id "${env_user}" &>/dev/null || \
		useradd --user-group --home-dir "${env_home}" "${env_user}"

	local env_template_dir="${SYSTEM_ROOT}/share/env"

	install -o "${env_user}" -g "${env_user}" -d "${env_home}"

	find /etc/skel "${env_template_dir}" -mindepth 1 -maxdepth 1 -exec \
		rsync -rEAX --chown="${env_user}:${env_user}" {} "${env_home}/" \;

	loginctl enable-linger "${env_user}"

	usermod -aG env_global "${env_user}"
}
export -f env::init::user

env::init::rootless_docker() {
	local env_user="${1}"
	local env_home="${2}"

	log INFO "Ensuring rootless dockerd configured and running for ${env_user}"

	local docker_config_root="${env_home}/.config/docker"

	sudo -u "${env_user}" mkdir -p "${docker_config_root}"
	cat <<CONFIG | sudo -u "${env_user}" tee "${docker_config_root}/daemon.json" >/dev/null 
{
	"storage-driver": "fuse-overlayfs"
}
CONFIG
	sudo -u "${env_user}" ln -sTf \
		"/run/user/$(id -u "${env_user}")/docker.sock" "${env_home}/.docker.sock"

	machinectl shell "${env_user}@" /usr/bin/dockerd-rootless-setuptool.sh install

	machinectl shell "${env_user}@" /usr/bin/systemctl --user stop docker
	machinectl shell "${env_user}@" /usr/bin/systemctl --user disable docker
}
export -f env::init::rootless_docker

env::init::pipeline_supervisor() {
	local env_user="${1}"
	local env_home="${2}"

	log INFO "Ensuring pipeline supervisor configured and runing for ${env_user}"

	local pipeline_root="${env_home}/pipelines"

	sudo -u "${env_user}" mkdir -p "${pipeline_root}"

	cat <<UNIT | sudo -u "${env_user}" tee "${env_home}/.config/systemd/user/pipeline-supervisor.service" >/dev/null
[Unit]
Description=Pipeline Supervisor

[Service]
ExecStart=/usr/bin/s6-svscan "${pipeline_root}"
Restart=always
WorkingDirectory=${pipeline_root}

[Install]
WantedBy=default.target
UNIT
	machinectl shell "${env_user}@" /usr/bin/systemctl --user daemon-reload
	machinectl shell "${env_user}@" /usr/bin/systemctl --user stop pipeline-supervisor
	machinectl shell "${env_user}@" /usr/bin/systemctl --user disable pipeline-supervisor
}
export -f env::init::pipeline_supervisor
