#!/usr/bin/env bash

set -e -u -o pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

# cluster name
_cluster_name="operator-sdk-dev"

# destroy previous cluster
k3d cluster delete "$_cluster_name" || true

# create cluster
_create_cmd="k3d cluster create"
# _create_cmd="$_create_cmd --k3s-server-arg '--disable=traefik'"
_create_cmd="$_create_cmd --registry-config "$DIR/registries.yml""
_create_cmd="$_create_cmd --api-port 6550"
_create_cmd="$_create_cmd --port '80:80@loadbalancer'"     # http
_create_cmd="$_create_cmd --port '443:443@loadbalancer'"   # https
_create_cmd="$_create_cmd --port '1883:1883@loadbalancer'" # mqtt
_create_cmd="$_create_cmd --port '8903:8903@loadbalancer'" # websockets
_create_cmd="$_create_cmd --agents 1"
_create_cmd="$_create_cmd '$_cluster_name'"
echo "$_create_cmd"
eval "$_create_cmd"

