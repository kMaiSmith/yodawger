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

include "<env>"

env::init() {
	local name="${1}"

	local env_user="$(env::get_user "${name}")"
	local env_home="$(env::get_home "${name}")"

	env::init::user "${env_user}" "${env_home}"
	env::init::slice "${env_user}"
	env::init::rootless_docker "${env_user}" "${env_home}"
}
export -f env::init

env::init::user() {
	local env_user="${1}"
	local env_home="${2}"


	if ! id "${env_user}" &>/dev/null; then
		log INFO "Creating env user ${env_user}"
		useradd --user-group --home-dir "${env_home}" "${env_user}"
	fi

	env::init::home "${env_user}" "${env_home}"

	usermod -aG env_global "${env_user}"
}
export -f env::init::user

env::init::home() {
	local env_user="${1}"
	local env_home="${2}"

	log INFO "ensuring home directory ${env_home} is configured for ${env_user}"

	local env_template_dir="${SYSTEM_ROOT}/tenants/template"

	chown "${env_user}:${env_user}" "${env_home}"
	install -o "${env_user}" -g "${env_user}" -d "${env_home}"

	find /etc/skel "${env_template_dir}" -mindepth 1 -maxdepth 1 -exec \
		rsync -rlEAX --chown="${env_user}:${env_user}" {} "${env_home}/" \;
}
export -f env::init::home

env::init::slice() {
	local env_user="${1}"

	cat <<SLICE >"/etc/systemd/system/${env_user}.slice"
[Unit]
Description=${env_user} Tenant Slice

[Install]
WantedBy=multi-user.target
SLICE

	systemctl daemon-reload
}

env::init::rootless_docker() {
       local env_user="${1}"
       local env_home="${2}"

       log INFO "Ensuring rootless dockerd configured and running for ${env_user}"

       local docker_config_root="${env_home}/.config/docker"

       sudo -u "${env_user}" mkdir -p "${docker_config_root}"
       cat <<CONFIG | sudo -u "${env_user}" tee "${docker_config_root}/daemon.json" >/dev/null 
{
       "storage-driver": "fuse-overlayfs",
       "exec-opts": ["native.cgroupdriver=cgroupfs"]
}
CONFIG
       sudo -u "${env_user}" ln -sTf \
               "/run/user/$(id -u "${env_user}")/docker.sock" "${env_home}/.docker.sock"

       machinectl shell "${env_user}@" /usr/bin/dockerd-rootless-setuptool.sh install

       machinectl shell "${env_user}@" /usr/bin/systemctl --user stop docker
       machinectl shell "${env_user}@" /usr/bin/systemctl --user disable docker
}
export -f env::init::rootless_docker

