#!/usr/bin/env bash
# @arg service
# @arg command
# @arg args~

set -ueo pipefail

eval "$(argc --argc-eval "${0}" "${@}")"

export SERVICE_NAME
SERVICE_NAME="${argc_service}"

source "common/script_lib.sh"

"${SERVICE_DIR}/bin/${SERVICE_NAME}" \
	"${argc_command}" \
	"${argc_args[@]}"

