#!/usr/bin/env bash

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
