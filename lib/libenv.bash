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

env::init() {
	local name="${1}"

	local _env_dir _env_conf _env_user="${name}_env"
	_env_dir="${SYSTEM_ROOT}/$(env_path "${name}")"
	_env_conf="${ENV_ROOT}/conf"
	id "${name}_env" &>/dev/null || \
		adduser --system --no-create-home \
			--group --home "${_env_dir}" "${name}_env"

	mkdir -p "${_env_dir}" "${_env_conf}"
	chown -R "${_env_user}:${_env_user}" "${_env_dir}"
}

env::daemon() {
	local name="${1}"

	local _runtime_dir="${SYSTEM_ROOT}/$(env_path "${name}")/.docker/run"
	mkdir -p "${_runtime_dir}"
	chown -R "${name}_env:${name}_env" "${_runtime_dir}"
	systemctl start "user@$(id -u "${name}_env")"

	sudo -u "${name}_env" \
		XDG_RUNTIME_DIR="${_runtime_dir}" \
		dockerd-rootless.sh

	systemctl stop "user@$(id -u "${name}_env")"
	rm -rf "${_runtime_dir}"
}
