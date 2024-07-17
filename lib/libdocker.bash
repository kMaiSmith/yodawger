#!/usr/bin/env bash

include "<system/sudo>"

#
#   Execute wrapped docker compose command to ensure it functions predictably
#
docker::compose() {
	local docker_socket

	docker_socket="/var/run/docker.sock"

	if [ -w "${docker_socket}" ]; then
		DOCKER_HOST="unix://${docker_socket}" docker compose \
			-f "${SERVICE_ROOT}/conf/docker-compose.yaml" \
			-p "${SERVICE_ENV}-${SERVICE_NAME}" \
			"${@}"
	else
		consented_sudo "${reason}, docker must be run as root until you reboot your mahine" \
			DOCKER_HOST="unix://${docker_socket}" docker compose \
				-f "${SERVICE_ROOT}/conf/docker-compose.yaml" \
				-p "${SERVICE_ENV}-${SERVICE_NAME}" \
				"${@}"
	fi
}
export -f docker::compose

# Expects:
# - DOCKER_IMAGE="registry/image:tag"
# - DOCKER_MOUNTS=("/host/path:/container/path" ...)
# - DOCkER_ENVS=(VAR="value" ...)
# - DOCKER_PORTS=("host:container" ...)
# - DOCKER_CMD=("cmd" "arg" ...)
docker::run() {
	local -a docker_args=()

	docker_args+=(
		"--network" "${SERVICE_ENV}"
		"--name" "${SERVICE_ENV}-${SERVICE_NAME}"
		"--user" "$(id -u "${SERVICE_ENV}_env"):$(id -g "${SERVICE_ENV}_env")"
	)

	for mount in "${DOCKER_MOUNTS[@]}"; do
		docker_args+=("--volume" "${mount}")
	done
	
	for env in "${DOCKER_ENVS[@]}"; do
		docker_args+=("--env" "${env}")
	done

	if [ "${SERVICE_ENV}" != "host" ]; then
		for port in "${DOCKER_PORTS[@]}"; do
			docker_args+=("--port" "127.0.0.1:${port}")
		done
	fi

	docker run "${docker_args[@]}" "${DOCKER_IMAGE}" "${DOCKER_CMD[@]}"
}
export -f docker::run

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

