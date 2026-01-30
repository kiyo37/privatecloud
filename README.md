# 自宅プライベートクラウド構築（1台完結・教材用）

本リポジトリは、**自宅の物理マシン1台**を使用して  
「プライベートクラウド風の構成」を構築・学習するための  
**教材兼 構築手順管理リポジトリ**です。

24時間稼働や冗長構成は前提とせず、  
**学習時のみ起動する環境**で、  
企業オンプレミスやプライベートクラウドの**設計思想を理解する**ことを目的としています。

---

## 🎯 目的

- 物理マシン1台で「クラウド的な構成」を再現する
- ネットワーク分離・役割分離を体験する
- Kubernetes を中心とした現場寄り構成を学ぶ
- 構築内容を **Git管理**し、再現・教材化できる形にする

---

## 🧩 前提条件・制約

- 物理マシン：**1台**
- 稼働：**学習時のみ**
- 物理スイッチ：**使用しない**
- ネットワーク分離：**Proxmox 内の仮想ブリッジで実現**
- VLAN：**使用しない（教材として不要）**

---

## 🏗 採用技術スタック

| レイヤ | 技術 |
|------|------|
| 仮想化基盤 | Proxmox VE |
| OS | Ubuntu Server |
| コンテナ | Docker / containerd |
| Kubernetes | k3s または kubeadm |
| Git | Gitea（self-hosted） |
| Registry | registry:2 / Harbor（任意） |
| 監視（後半） | Prometheus / Grafana |
| ログ（任意） | Loki |

---

## 🌐 ネットワーク設計（重要）

### 仮想ブリッジ構成（Proxmox）

| Bridge | 用途 | 説明 |
|------|------|------|
| vmbr0 | 管理・外部通信 | Proxmox管理GUI / VMの外部通信 |
| vmbr1 | 内部（閉域） | VM間の内部通信専用 |

- `vmbr1` は **物理NICに接続しない**
- 物理スイッチなしでも **論理的なネットワーク分離**を実現
- 教材として「管理NW / プライベートNW」の考え方を学ぶ

---

## 🖥 VM構成（最小・教材向け）

### 1. infra-mgmt（管理用VM）
- OS：Ubuntu Server
- 役割：
  - kubectl / helm
  - Git クライアント
  - Terraform / Ansible（将来導入）
- Network：
  - vmbr0（必須）
  - vmbr1（任意）

👉 **構築・運用の司令塔**

---

### 2. k8s-cp（Kubernetes Control Plane）
- OS：Ubuntu Server
- 役割：
  - Kubernetes Control Plane
- Network：
  - vmbr1（必須）
  - vmbr0（任意）

👉 **Control Plane の役割理解用**

---

### 3. k8s-worker（Kubernetes Worker）
- OS：Ubuntu Server
- 役割：
  - Kubernetes Worker Node
- Network：
  - vmbr1（必須）
  - vmbr0（任意）

👉 **Pod配置・スケジューリング学習用**

---

### 4. shared-svcs（共通サービスVM）
- OS：Ubuntu Server
- 役割：
  - Gitea（Git）
  - Container Registry
  - 監視・ログ（後半教材）
- Network：
  - vmbr1（必須）
  - vmbr0（任意）

👉 **Kubernetes 外部サービス連携の実践**

---

## 📘 この構成で扱う学習スコープ

### Kubernetes 基礎
- Pod / Deployment / Service
- Namespace
- ConfigMap / Secret

### 実務寄り
- InitContainer
- Ingress / Gateway API
- Resource requests / limits
- PVC（段階的に）

### 運用
- GitOps（Argo CD）
- 監視（Prometheus / Grafana）
- ログ収集（Loki）

---

## 🗂 Git管理方針

### 管理対象
- VM構成・役割設計
- 各VMのセットアップ手順
- Kubernetes マニフェスト
- 共通サービスの構築手順
- 教材用ドキュメント

### 管理しないもの
- 秘密情報（鍵・トークン）
- 実データ（DB・ログ）
- 個人環境依存の値  
  → `example` / `sample` としてテンプレ化する

---

## ▶ 運用方針（学習前提）

- 原則：**必要なときだけ起動**
- 節目で Proxmox Snapshot を取得
- 意図的に壊して直す演習を想定

---

## 📂 リポジトリ構成（予定）

