# etcd Restore Runbook (Lab)

## Purpose
Document recovery steps for etcd snapshot restoration.

---

## Step 1: Verify snapshot

```bash
etcdutl snapshot status /backup/etcd/snapshot-XXXX.db --write-out=table
