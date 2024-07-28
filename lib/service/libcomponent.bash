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
export SHELLOPTS

include "<system/network>"

service::component::init() {
	local component_path="${1}"

	export SERVICE_NAME COMPONENT_NAME COMPONENT_DATA COMPONENT_CONF \
		COMPONENT_SOCKET
	SERVICE_NAME="$(basename "$(dirname "${component_path}")")"
	COMPONENT_NAME="$(basename "${component_path}")"

	COMPONENT_DATA="${component_path}/data"
	COMPONENT_CONF="${component_path}/conf"
	COMPONENT_SOCKET="${component_path}/socket"

	mkdir -p "${COMPONENT_DATA}" "${COMPONENT_CONF}" "${COMPONENT_SOCKET}"
}
export -f service::component::init

