#!/usr/bin/env bash

export GENERIC_SERVICE_http="caddy"
export GENERIC_SERVICE_dns="bind9"

generic::is_registered() {
	local _generic="${1}"
	local -a _generic_services=()

	readarray -t _generic_services < <(
 		export | \
			awk '{print $3}' | \
			cut -d'=' -f1 | \
			grep "GENERIC_SERVICE_" | \
			sed -e 's/GENERIC_SERVICE_//'
	)

	[[ " ${_generic_services[*]} " == *" ${_generic} "* ]]	
}
export -f generic::is_registered 

generic::set() {
	local _generic="${1}"
	local _service="${2-}"
	generic::is_registered "${_generic}" || return

	local -n _generic_var="GENERIC_SERVICE_${_generic}"
	_generic_var="${_service}"

	sed -i "s/^export GENERIC_SERVICE_${_generic}=.*/export GENERIC_SERVICE_${_generic}=\"${_service-}\"/" \
		"${BASH_SOURCE[0]}"
}
export -f generic::set

generic::get() {
	local _generic="${1}"
	local -n _service="GENERIC_SERVICE_${_generic}"

	echo "${_service}"
}
export -f generic::get

