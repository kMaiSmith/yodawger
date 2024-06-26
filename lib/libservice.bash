#!/usr/bin/env bash


service::discover() {
	local _name="${1}"

	export SERVICE_NAME SERVICE_ROOT SERVICE_ENV SERVICE_ENV_ROOT \
		ENV_ROOT SERVICE_CONF
	SERVICE_NAME="${_name}"
	SERVICE_ROOT="$(find "${SYSTEM_ROOT}/services" \
			-maxdepth 1 -mindepth 1 \
			-name "${SERVICE_NAME}")"
	if [ -f "${SERVICE_ROOT}/force-env" ]; then
		SERVICE_ENV="$(cat "${SERVICE_ROOT}/force-env" | xargs -r)"
	else
		SERVICE_ENV="${argc_env}"
	fi
	exists "${SERVICE_ENV}" || \
		error "Yodawg environment ${SERVICE_ENV} does not exist"
	SERVICE_ENV_ROOT="${SERVICE_ROOT}/env/${SERVICE_ENV}"
	ENV_ROOT="${SYSTEM_ROOT}/$(env_path "${SERVICE_ENV}")service/${SERVICE_NAME}"
	SERVICE_CONF="${SERVICE_ROOT}/conf"
}

service::init() {
	export SERVICE_DATA SERVICE_ENV_CONF SERVICE_LOG SERVICE_CACHE

	[ "$(readlink -f "${SERVICE_ENV_ROOT}")" = "${ENV_ROOT}" ] || \
		service::init_dir

	SERVICE_DATA="${SERVICE_ENV_ROOT}/data"
	SERVICE_ENV_CONF="${SERVICE_ENV_ROOT}/conf"
	SERVICE_LOG="${SERVICE_ENV_ROOT}/log"
	SERVICE_CACHE="${SERVICE_ENV_ROOT}/cache"

	mkdir -p "${SERVICE_DATA}" "${SERVICE_ENV_CONF}" \
		"${SERVICE_LOG}" "${SERVICE_CACHE}"

	service::init_configs
}

service::init_dir() {
	if [ -d "${SERVICE_ENV_ROOT}" ] && [ ! -d "${ENV_ROOT}" ]; then
		mkdir -p "$(dirname "${ENV_ROOT}")"
		mv "${SERVICE_ENV_ROOT}" "${ENV_ROOT}"
	elif [ -L "${SERVICE_ENV_ROOT}" ] && [ "$(readlink -f "${SERVICE_ENV_ROOT}")" != "${ENV_ROOT}" ]; then
		error "directory aleady exists for service ${SERVICE_NAME} in env ${SERVICE_ENV} (${ENV_ROOT})"
	else
		mkdir -p "${ENV_ROOT}"
	fi

	ln -sf "${ENV_ROOT}" "${SERVICE_ENV_ROOT}"
}

service::init_configs() {
	set -a
	if [ -f "${SERVICE_ROOT}/config.sh" ]; then
		source "${SERVICE_ROOT}/config.sh"
	fi
	if [ -f "${SERVICE_ENV_ROOT}/config.sh" ]; then
		source "${SERVICE_ENV_ROOT}/config.sh"
	fi
}

service::list() {
	find "${SYSTEM_ROOT}/services" \
		-maxdepth 1 -mindepth 1 -type d| \
		xargs -rL1 basename
	exit
}
