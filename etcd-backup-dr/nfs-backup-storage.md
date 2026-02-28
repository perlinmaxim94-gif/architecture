# NFS backup storage for etcd snapshots

## Goal
Provide off-cluster storage for etcd snapshots. Snapshots are written to `/backup/etcd` on masters, backed by NFS export from `backup01`.

---

# Server side (backup01)

### Install NFS server

Debian/Ubuntu:
```bash
sudo apt-get update && sudo apt-get install -y nfs-kernel-server


Create export directory
sudo mkdir -p /srv/backup/etcd
sudo chown -R root:root /srv/backup/etcd
sudo chmod 0770 /srv/backup/etcd



Export config
Replace subnet with your masters network.
sudo tee /etc/exports >/dev/null <<'EOF'
/srv/backup/etcd 192.168.31.0/24(rw,sync,no_subtree_check,root_squash)
EOF
sudo exportfs -ra

Validate exports
showmount -e 127.0.0.1


Client side (k8s master node)
Install NFS client

Debian/Ubuntu:

sudo apt-get update && sudo apt-get install -y nfs-common

RHEL/CentOS/Alma/Rocky:

sudo yum install -y nfs-utils
Mount
sudo mkdir -p /backup/etcd
sudo mount -t nfs 192.168.31.66:/srv/backup/etcd /backup/etcd
Persist in fstab
192.168.31.66:/srv/backup/etcd  /backup/etcd  nfs  defaults,_netdev  0  0
Verify mount is NFS
stat -f -c '%T' /backup/etcd
mount | grep ' /backup/etcd '






