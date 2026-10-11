#!/usr/bin/env bash
#shellcheck disable=SC2312
set -euo pipefail
TAILSCALE_API_KEY="${TAILSCALE_API_KEY:-}"
OAUTH_CLIENT_ID="${OAUTH_CLIENT_ID:-}"
OAUTH_CLIENT_SECRET="${OAUTH_CLIENT_SECRET:-}"
TAILSCALE_TAILNET="${TAILSCALE_TAILNET:?Please supply a TAILSCALE_TAILNET}"
tscli() {
	go run github.com/jaxxstorm/tscli/cmd/tscli@latest "${@}"
}
get_bearer() {
	if [[ -n "${TAILSCALE_API_KEY}" ]]; then
		return 0
	else
		if [[ -n "${OAUTH_CLIENT_ID}" && -n "${OAUTH_CLIENT_SECRET}" ]]; then
			local endpoint response
			endpoint="https://api.tailscale.com/api/v2/oauth/token"
			response="$(
				curl --silent \
					-d "client_id=${OAUTH_CLIENT_ID}" \
					-d "client_secret=${OAUTH_CLIENT_SECRET}" \
					"${endpoint}"
				)"
			TAILSCALE_API_KEY="$(jq -r .access_token <<< "${response}")"
			export TAILSCALE_API_KEY
		else
			echo "Please supply either TAILSCALE_API_KEY or OAUTH_CLIENT_ID and OAUTH_CLIENT_SECRET" 1>&2
			exit 1
		fi
	fi
}

get_policy() {
	tscli get policy
}
get_bearer
get_policy > policy.hujson
truncate -s -1 policy.hujson # remove the spurious extra newline

git diff --exit-code 1>&2
