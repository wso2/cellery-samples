#!/bin/bash
echo Duration = "$DURATION"
echo Concurrency = "$CONCURRENCY"
echo URL = "$PET_STORE_INST"

hey -z "$DURATION" -c "$CONCURRENCY" http://"$PET_STORE_INST"--gateway-service/controller/catalog