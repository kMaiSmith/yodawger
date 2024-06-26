#!/usr/bin/env bash


get_public_ip() {
	local public_ip_file="${SYSTEM_CONF}/public_ip"

	[ -f "${public_ip_file}" ] || \
		curl -SsL https://wtfismyip.com/text > "${public_ip_file}"

	cat "${public_ip_file}"
}

