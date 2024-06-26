#!/usr/bin/env bash

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

