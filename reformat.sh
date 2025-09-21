#!/usr/bin/env bash
set -euxo pipefail
shopt -s globstar
if command -v go >/dev/null 2>&1; then
  go run github.com/tailscale/hujson/cmd/hujsonfmt@latest -w ./**/*.hujson ./*.hujson
else
  docker run --rm -v.:/work -w/work docker.io/golang:latest \
    go run github.com/tailscale/hujson/cmd/hujsonfmt@latest -w ./**/*.hujson ./*.hujson
fi