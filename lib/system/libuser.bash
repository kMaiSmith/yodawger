#!/usr/bin/bash

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
