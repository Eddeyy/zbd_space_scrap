#!/bin/bash

for dir in /docker-entrypoint-initdb.d/*; do
    if [ -d "$dir" ]; then
        for sql_file in "$dir"/*.sql; do
            echo "[INITDB.SH] Executing $sql_file"
            psql -U postgres -d "$POSTGRES_DB" -f "$sql_file"
        done
    fi
done
