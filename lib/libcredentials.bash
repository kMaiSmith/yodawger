#!/usr/bin/env bash

get_password() {
	local _name="${1:-"default"}"
	local _password_file="${SERVICE_ENV_CONF}/password.${_name}"

	[ -f "${_password_file}" ] || \
		date +%s | sha256sum | base64 | head -c 32 > "${_password_file}"

	chmod 600 "${_password_file}"
	cat "${_password_file}"
}
export -f get_password

