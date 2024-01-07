# This script tries to autoheal an expired SSL certificate by force renewing the underlying certificate from an `nginxproxy/acme-companion` container.

if [ -z "$ACME_COMPANION_CONTAINER" ]; then
    echo "ACME_COMPANION_CONTAINER is not set. Unable to auto-heal"
    exit 0
fi

if [ ! -S /var/run/docker.sock ]; then
    echo "Docker socket is not mounted. Unable to auto-heal"
    exit 0
fi


docker exec -t $ACME_COMPANION_CONTAINER /app/force_renew

# Killing container so it can restart with new certificates
kill -s 15 -1 && (sleep 10; kill -s 9 -1)