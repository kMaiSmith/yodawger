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

include "<system/package>"
include "<system/sudo>"

#
#   Set up all the necessary docker component to be able to bootstrap a MOO
# system, including: Docker itself to containerize the operator containers,
# the docker compose plugin to simplify container orchestration, and sysbox
# to enable a tiered hierarcy of independantly operating container systems
# (read: Docker in Docker, or Kubernetes in Docker)
#
setup_docker() {
	if ! package_installed docker.io; then
		consented_sudo "install the docker.io package" \
			apt install -y docker.io
	fi

	if ! [ "$(id -u)" = 0 ] && ! id -nG | grep -qw 'docker'; then
		consented_sudo "add ${USER} (yourself) to the 'docker' group" \
			usermod -aG docker ${USER}
	fi

	if ! package_installed rootlesskit; then
		consented_sudo "install rootlesskit to enable rootless docker daemons" \
			apt install -y "rootlesskit"
	fi

	local cli_plugins_dir="/usr/local/lib/docker/cli-plugins"
	if ! [ -f "${cli_plugins_dir}/docker-compose" ]; then
		local compose_version="2.24.7"
		local compose_base_url="https://github.com/docker/compose/releases/download"

		if ! [ -d "${cli_plugins_dir}" ]; then
			consented_sudo "make the global cli-plguins directory to install docker-compose into" \
				mkdir -p "${cli_plugins_dir}"
		fi

		consented_sudo "download and install docker compose into the global docker cli-plugins directory" \
			wget "${compose_base_url}/v${compose_version}/docker-compose-linux-x86_64" \
				-O "${cli_plugins_dir}/docker-compose"

		consented_sudo "Add the executable bit to the docker compose plugin" \
			chmod +x "${cli_plugins_dir}/docker-compose"
	fi
	if ! [ -e "/usr/bin/dockerd-rootless-setuptool.sh" ]; then
		ln -sf "/usr/share/docker.io/contrib/dockerd-rootless-setup.sh" \
			"/usr/bin/dockerd-rootless-setup.sh"
	fi
	if ! [ -e "/usr/bin/dockerd-rootless.sh" ]; then
		ln -sf "/usr/share/docker.io/contrib/dockerd-rootless.sh" \
			"/usr/bin/dockerd-rootless.sh"
	fi
}

setup_argc() {
	if ! command -v argc &>/dev/null; then
		consented_sudo "install argc to /usr/local/bin for command line argument processing" \
			bash -c "curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sh -s -- --to /usr/local/bin"
	fi
}

setup_systemd() {
	if ! [ -L "/etc/systemd/system/yodawg_env@.service" ]; then
		ln -sf "${SYSTEM_ROOT}/lib/systemd/yodawg_env@.service" \
			"/etc/systemd/system/yodawg_env@.service"
		systemctl daemon-reload
	fi
}

