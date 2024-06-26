export GENERIC_SERVICE_http="caddy"
export GENERIC_SERVICE_dns="bind9"

_is_generic() {
	local _generic="${1}"
	local -a _generic_services=()

	readarray -t _generic_services < <(
 		export | \
			awk '{print $3}' | \
			cut -d'=' -f1 | \
			grep "GENERIC_SERVICE_" | \
			sed -e 's/GENERIC_SERVICE_//'
	)
	echo "Generic Services: ${_generic_services[*]}"

	[[ " ${_generic_services[*]} " == *" ${_generic} "* ]]	
}
export -f _is_generic

_set_generic() {
	local _generic="${1}"
	local _service="${2-}"
	_is_generic "${_generic}" || return

	local -n _generic_var="GENERIC_SERVICE_${_generic}"
	_generic_var="${_service}"

	sed -i "s/^export GENERIC_SERVICE_${_generic}=.*/export GENERIC_SERVICE_${_generic}=\"${_service-}\"/" \
		"${SYSTEM_ROOT}/common/generics.sh"
}
export -f _set_generic

_get_generic() {
	local _generic="${1}"
	local -n _service="GENERIC_SERVICE_${_generic}"

	echo "${_service}"
}
export -f _get_generic

