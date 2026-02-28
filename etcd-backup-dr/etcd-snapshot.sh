#!/usr/bin/env bash
set -euo pipefail

source /etc/etcd.env

BACKUP_DIR="/backup/etcd"
RETENTION_DAYS=14

# All masters etcd client endpoints
ENDPOINTS=(
  "https://192.168.31.224:2379"
  "https://192.168.31.215:2379"
  "https://192.168.31.76:2379"
)

TS="$(date -u +'%Y-%m-%dT%H-%M-%SZ')"
SNAP_FILE="${BACKUP_DIR}/snapshot-${TS}.db"
HOST="$(hostname -s)"

log() { echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"; }

mkdir -p "$BACKUP_DIR"
stat -f -c %T "$BACKUP_DIR" | grep -qi nfs || { log "ERROR: $BACKUP_DIR is not NFS"; exit 1; }

# 1) Health check all endpoints (informational but useful)
log "Checking endpoints health..."
ETCDCTL_API=3 etcdctl \
  --endpoints="$(IFS=,; echo "${ENDPOINTS[*]}")" \
  --cacert="${ETCDCTL_CACERT}" \
  --cert="${ETCDCTL_CERT}" \
  --key="${ETCDCTL_KEY}" \
  endpoint health

# 2) Pick first healthy endpoint for snapshot
SNAP_ENDPOINT=""
for ep in "${ENDPOINTS[@]}"; do
  if ETCDCTL_API=3 etcdctl \
      --endpoints="$ep" \
      --cacert="${ETCDCTL_CACERT}" \
      --cert="${ETCDCTL_CERT}" \
      --key="${ETCDCTL_KEY}" \
      endpoint health >/dev/null 2>&1; then
    SNAP_ENDPOINT="$ep"
    break
  fi
done

if [[ -z "$SNAP_ENDPOINT" ]]; then
  log "ERROR: no healthy etcd endpoint found for snapshot"
  exit 1
fi

log "Creating snapshot using endpoint: ${SNAP_ENDPOINT}"
ETCDCTL_API=3 etcdctl \
  --endpoints="${SNAP_ENDPOINT}" \
  --cacert="${ETCDCTL_CACERT}" \
  --cert="${ETCDCTL_CERT}" \
  --key="${ETCDCTL_KEY}" \
  snapshot save "${SNAP_FILE}"

chmod 0640 "${SNAP_FILE}"

log "Validating snapshot..."
etcdutl snapshot status "${SNAP_FILE}" --write-out=table

cat > "${SNAP_FILE}.meta" <<META
created_by=${HOST}
created_at=${TS}
snapshot_endpoint=${SNAP_ENDPOINT}
META
chmod 0640 "${SNAP_FILE}.meta"

log "Applying retention (${RETENTION_DAYS} days)..."
find "${BACKUP_DIR}" -type f -name 'snapshot-*.db' -mtime +"${RETENTION_DAYS}" -delete
find "${BACKUP_DIR}" -type f -name 'snapshot-*.meta' -mtime +"${RETENTION_DAYS}" -delete

log "Done: ${SNAP_FILE}"
~
~
~
~
