#!/usr/bin/env bash

env_path() {
	local IFS=":"
	local _path=""

	for subenv in ${1}; do
		_path+="env/${subenv}/"
	done
	echo "${_path}"
}
export -f env_path

env::get_default() {
	local default_env_file="${SYSTEM_CONF}/default_env"

	[ -f "${default_env_file}" ] || \
		echo "default" > "${default_env_file}"

	cat "${default_env_file}"
}

