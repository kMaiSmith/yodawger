#!/usr/bin/env bash
# @arg service
# @arg command
# @arg args~

set -ueo pipefail

eval "$(argc --argc-eval "${0}" "${@}")"

export SERVICE_NAME SERVICE_DIR SERVICE_PORT SERVICE_DATA \
	SERVICES_ROOT SERVICE_CACHE ENVIRONMENT
SERVICES_ROOT="/Applications"
SERVICE_NAME="${argc_service}"
SERVICE_DIR="$(find "${SERVICES_ROOT}" \
		-maxdepth 1 -mindepth 1 \
		-iname "${SERVICE_NAME}.service")"
SERVICE_DATA="${SERVICE_DIR}/data"
SERVICE_CACHE="${SERVICE_DIR}/.service"
ENVIRONMENT="default"
mkdir -p "${SERVICE_CACHE}"

set -a
source "${SERVICES_ROOT}/common/script_lib.sh"
source "${SERVICE_DIR}/env/${ENVIRONMENT}"

SERVICE_PORT="$(_get_active_port || _get_free_port)"

s() {
	env -i "${SERVICES_ROOT}/s" "${@}"
}
export s

"${SERVICE_DIR}/bin/${SERVICE_NAME}" \
	"${argc_command}" \
	"${argc_args[@]}"

