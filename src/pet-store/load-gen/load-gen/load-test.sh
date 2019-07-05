#!/bin/bash
echo Duration = "$DURATION"
echo Concurrency = "$CONCURRENCY"
echo Instance = "$PET_BE_INSTANCE"

hey -z "$DURATION" -c "$CONCURRENCY" http://"$PET_BE_INSTANCE"--gateway-service/controller/catalog