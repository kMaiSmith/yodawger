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

#
#   Prove that an apt package is installed and configured correctly
#
package_installed() {
	local package_name="${1}"
	local package_status
	package_status="$(
		dpkg -l | grep -w "${package_name}" | head -n 1 | awk '{print $1}'
	)"

	[ "${package_status}" = "ii" ]
}
export -f package_installed

