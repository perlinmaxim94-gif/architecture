# etcd Restore Runbook (Lab)

## Purpose
Document recovery steps for etcd snapshot restoration.

---

## Step 1: Verify snapshot

```bash
etcdutl snapshot status /backup/etcd/snapshot-XXXX.db --write-out=table

## Step 2: Restore to isolated directory (validation)
sudo rm -rf /var/lib/etcd-restore-test
sudo etcdutl snapshot restore \
  /backup/etcd/snapshot-XXXX.db \
  --data-dir /var/lib/etcd-restore-test

Verify:
ls -lah /var/lib/etcd-restore-test
du -sh /var/lib/etcd-restore-test
