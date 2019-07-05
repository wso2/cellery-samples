#!/bin/bash
echo Duration = "$DURATION"
echo Concurrency = "$CONCURRENCY"
echo URL = "$PET_STOE_BE_CELL_URL"

hey -z "$DURATION" -c "$CONCURRENCY" "$PET_STOE_BE_CELL_URL"/catalog