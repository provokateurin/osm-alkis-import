#!/usr/bin/env bash

go run github.com/sqlc-dev/sqlc/cmd/sqlc@v1.26.0 generate -f pkg/db/sqlc.yaml
