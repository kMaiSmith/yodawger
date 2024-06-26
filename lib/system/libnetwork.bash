#!/usr/bin/env bash


get_public_ip() {
	local public_ip_file="${SYSTEM_CONF}/public_ip"

	[ -f "${public_ip_file}" ] || \
		curl -SsL https://wtfismyip.com/text > "${public_ip_file}"

	cat "${public_ip_file}"
}

get_port() {
	local _name="${1:-"default"}"
	local _port_file="${SERVICE_ENV_CONF}/port.${_name}"

	[ -f "${_port_file}" ] || \
		python3 <<PYTHON > "${_port_file}"
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 0))
addr = s.getsockname()
print(addr[1])
s.close()
PYTHON

	cat "${_port_file}"
}
export -f get_port
