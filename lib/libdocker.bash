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

include "<system/sudo>"

export DOCKER_HOST
DOCKER_HOST="unix://${HOME}/.docker.sock"

#
#   Execute wrapped docker compose command to ensure it functions predictably
#
docker::compose() {
	docker compose \
		-f "${SERVICE_ROOT}/conf/docker-compose.yaml" \
		-p "${SERVICE_NAME}" \
		"${@}"
}
export -f docker::compose

# Expects:
# - DOCKER_IMAGE="registry/image:tag"
# - DOCKER_MOUNTS=("/host/path:/container/path" ...)
# - DOCkER_ENVS=(VAR="value" ...)
# - DOCKER_CMD=("cmd" "arg" ...)
docker::exec_run() {
	local -a docker_args=()

	docker_args+=(
		"--name" "${SERVICE_NAME}-${COMPONENT_NAME}"
		"--rm"
	)

	for mount in "${DOCKER_MOUNTS[@]}"; do
		docker_args+=("--volume" "${mount}")
	done
	
	for env in "${DOCKER_ENVS[@]}"; do
		docker_args+=("--env" "${env}")
	done

	exec docker run "${docker_args[@]}" "${DOCKER_IMAGE}" "${DOCKER_CMD[@]}" 2>&1
}
export -f docker::exec_run

docker::network::create() {
	log INFO "Creating network ${SERVICE_NETWORK}"
	docker network inspect "${SERVICE_NETWORK}" &>/dev/null || \
		docker network create "${SERVICE_NETWORK}"
}
export -f docker::network::create

docker::network::rm() {
	docker network inspect "${SERVICE_NETWORK}" &>/dev/null
	docker network rm "${SERVICE_NETWORK}"
}
export -f docker::network::rm

