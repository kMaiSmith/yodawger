#!/usr/bin/env bash

#
#   Execute wrapped docker compose command to ensure it functions predictably
#
docker_compose() {
	local docker_socket

	docker_socket="${SYSTEM_ROOT}/$(env_path "${SERVICE_ENV}")/.docker/run/docker.sock"

	if [ -w "${docker_socket}" ]; then
		DOCKER_HOST="unix://${docker_socket}" docker compose \
			-f "${SERVICE_ROOT}/conf/docker-compose.yaml" \
			-p "${SERVICE_NAME}" \
			"${@}"
	else
		consented_sudo "${reason}, docker must be run as root until you reboot your mahine" \
			DOCKER_HOST="unix://${docker_socket}" docker compose \
				-f "${SERVICE_ROOT}/conf/docker-compose.yaml" \
				-p "${SERVICE_NAME}" \
				"${@}"
	fi
}
export -f docker_compose
