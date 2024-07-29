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

set -ueo pipefail

s6::exec_svscan() {
	local base_dir="${1}"
	local instance_name="${2-}"
	local scan_dir="${base_dir}/.run"

	if [ -x "${base_dir}/init" ]; then
		"${base_dir}/init" "${instance_name-}"
	fi

	mkdir -p "${scan_dir}"

	exec s6-svscan "${scan_dir}" 2>&1
}
export -f s6::exec_svscan

s6::populate_services() {
	local base_dir="${1}"
	local scan_dir="${base_dir}/.run"

	mkdir -p "${scan_dir}"
	readarray -t services < <(
		find "${base_dir}" -mindepth 2 -maxdepth 2 -name "run" -exec dirname {} \;
	)

	log INFO "There are ${#services[@]} services in ${base_dir}"
	for service in "${services[@]}"; do
		if [ "$(basename "${service}")" = "log" ]; then continue; fi

		log INFO "Adding service ${service} to the run services"

		ln -sft "${scan_dir}" "${service}"

		s6::init_service "${service}"
	done
}
export -f s6::populate_services

s6::init_service() {
	local path="${1}"

	mkdir -p "${path}/log"

	ln -sf "/yodawg/bin/run/log" "${path}/log/run"
	ln -sf "/yodawg/bin/finish/svscan" "${path}/finish"
}
export -f s6::init_service

