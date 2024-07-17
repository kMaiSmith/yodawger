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

#   Whenever this script needs to perform a privileged operation, it will
# request consent to perform the operation from the script operator, including
# an effective description of what is being performed and why
#
consented_sudo() {
	local reason="${1}"; shift

	cat <<SUDO
===================== !!!!! RUNNING SUDO !!!!! ======================

In order to ${reason},
This script needs to run the following sudo command:

	> sudo ${*}

=====================================================================

SUDO

	while read -rN 1 \
		-p "Is this script allowed to perform this sudo command? (y/n) " consent
	do
		echo
		case "${consent}" in
		y|Y) break;;
		n|N) return 1;;
		esac
	done

	sudo "${@}"
}
export -f consented_sudo
