#!/usr/bin/bash
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

get_next_subuid_range() { set -ueo pipefail
	local _last_subuid="$(tail -n1 /etc/subuid | cut -d: -f2)"
	local _subuid_start="$(( _last_subuid + 100000 ))"
	local _subuid_end="$(( _subuid_start + 99999 ))"

	echo "${_subuid_start}-${_subuid_end}"
}

get_next_subgid_range() { set -ueo pipefail
	local _last_subgid="$(tail -n1 /etc/subgid | cut -d: -f2)"
	local _subgid_start="$(( _last_subgid + 100000 ))"
	local _subgid_end="$(( _subgid_start + 99999 ))"

	echo "${_subgid_start}-${_subgid_end}"
}
