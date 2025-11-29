#!/bin/sh
# POSIX-compliant shell script - uses only basic shell features
set -e

# Check if the app directory exists (indicates submodule was initialized)
if [ ! -d "/app/app" ]; then
    echo ""
    echo "============================================================"
    echo "ERROR: The potpie-ui submodule is not initialized!"
    echo "============================================================"
    echo ""
    echo "The /app/app directory is missing. This usually means the"
    echo "potpie-ui git submodule was not cloned properly."
    echo ""
    echo "To fix this, run the following commands from the potpie root:"
    echo ""
    echo "    git submodule update --init --recursive"
    echo ""
    echo "Then restart the container:"
    echo ""
    echo "    docker compose restart frontend"
    echo ""
    echo "============================================================"
    echo ""
    exit 1
fi

# Check if package.json exists
if [ ! -f "/app/package.json" ]; then
    echo ""
    echo "ERROR: package.json not found in /app"
    echo "The potpie-ui directory may be empty or corrupted."
    echo ""
    exit 1
fi

exec "$@"
