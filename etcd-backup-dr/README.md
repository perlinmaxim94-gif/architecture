# architecture
# etcd Backup & Disaster Recovery (Lab Architecture)

## Overview

This project documents a production-style hardening of etcd backup and disaster recovery strategy
for a Kubernetes control-plane (3 masters, stacked etcd).

The goal was to move from "basic snapshot script" to a validated, off-cluster, recoverable backup system.

---

# 🇷🇺 Русская версия

## Цель

Настроить корректные off-cluster бэкапы etcd с проверкой восстановления (restore drill)
и документированным DR-процессом.

## Исходное состояние

- 3 control-plane ноды
- stacked etcd
- snapshot скрипт запускался на каждом мастере
- бэкапы хранились локально
- восстановление не тестировалось

## Улучшения

### 1. Off-cluster хранение
- Настроен NFS backup target
- Снапшоты сохраняются в `/backup/etcd`
- Проверяется, что каталог является NFS mount

### 2. Multi-endpoint health check
- Проверка здоровья всех etcd endpoints
- Snapshot выполняется через выбранный healthy endpoint

### 3. Использование client certificates
- Используются ETCDCTL_CERT / KEY / CACERT
- Исключено использование peer cert

### 4. Retention policy
- Хранение снапшотов 14 дней

### 5. Restore drill
- Snapshot восстанавливается в изолированный каталог
- Подтверждается корректность восстановления
- Метка restore сохраняется в .meta файле

## Результат

- Реальный DR-уровень для control-plane
- Проверяемая процедура восстановления
- Документированный процесс

---

# 🇬🇧 English Version

## Goal

Implement production-grade etcd backup and disaster recovery validation
for a Kubernetes control-plane (3 masters, stacked etcd).

## Initial State

- 3 control-plane nodes
- stacked etcd
- local snapshot script
- no off-cluster storage
- no restore validation

## Improvements

### 1. Off-cluster storage
- NFS backup target configured
- Snapshots stored in `/backup/etcd`
- Mount validation added to prevent local writes

### 2. Endpoint health validation
- All etcd endpoints checked before snapshot
- Snapshot taken from selected healthy endpoint

### 3. Client certificates
- Proper ETCDCTL_CERT/KEY/CACERT used
- No peer cert misuse

### 4. Retention policy
- 14-day snapshot retention

### 5. Restore drill validation
- Snapshot restored into isolated data directory
- Integrity verified using `etcdutl`
- Metadata file updated with restore test timestamp

## Outcome

- Verified control-plane DR capability
- Off-cluster etcd backups
- Documented and reproducible recovery process
