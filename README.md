# Proxmox + Terraform で自宅プライベートクラウド構築（Phase1確実成功）

目的: Proxmox上でCloud-Initテンプレを用意し、TerraformでVMを量産できる状態にする。  
まずは「Terraformで1台VM作成 → SSH接続成功」を最短で実現します。

---

## TL;DR（最短手順）

1. ProxmoxでAPI Tokenを作る  
2. Ubuntu 24.04 cloud imageからCloud-Initテンプレを作る（VMID 9000）  
3. `terraform/` に移動して `terraform init && terraform apply`  
4. Proxmox UIでDHCP割当IPを確認してSSH接続

---

## 前提

- Proxmox VE: `https://192.168.1.50:8006`
- ノード名: `pve`
- ストレージ: `local`（イメージ置き場）、`local-lvm`（VMディスク）
- ブリッジ: `vmbr0`
- OS: Ubuntu Server 24.04 LTS cloud image
- VMテンプレID: `9000`（衝突したら変更可）

---

## 1. Proxmox準備（API Token）

### 1-1. ユーザー作成
- `Datacenter` → `Permissions` → `Users` → `Add`
- User: `terraform`
- Realm: `pve`

### 1-2. 役割（Role）作成（最小権限の例）
- `Datacenter` → `Permissions` → `Roles` → `Create`
- Role name: `TerraformRole`
- 付与する権限（最低限の目安）
  - `Datastore.Audit`
  - `Datastore.AllocateSpace`
  - `Datastore.AllocateTemplate`
  - `VM.Audit`
  - `VM.Allocate`
  - `VM.Clone`
  - `VM.Config.CPU`
  - `VM.Config.Memory`
  - `VM.Config.Disk`
  - `VM.Config.Network`
  - `VM.Config.Cloudinit`
  - `VM.Config.Options`
  - `VM.PowerMgmt`
  - `Sys.Audit`

※ もし権限エラーが出たら、まずは一時的に `PVEVMAdmin` でもOK（後で絞る）。

### 1-3. ACL付与
- `Datacenter` → `Permissions` → `Add` → `User Permission`
- Path: `/`
- User: `terraform@pve`
- Role: `TerraformRole`
- Propagate: ON

### 1-4. API Token作成
- `Datacenter` → `Permissions` → `API Tokens` → `Add`
- User: `terraform@pve`
- Token ID: `tf`
- Privilege Separation: **OFF**（User権限を使う）

生成された **Token Secret** を保存しておく。

---

## 2. Cloud-Initテンプレ作成（Ubuntu 24.04）

### 2-1. CLIで作る（推奨）
Proxmoxノード（`pve`）のShellで実行:

```bash
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

qm create 9000 --name ubuntu-2404-cloudinit --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 9000 /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000
```

### 2-2. GUIで作る（代替）
1. `local` → `ISO Images` に cloud image をアップロード  
2. VMを作成（VMID 9000）  
3. Diskをcloud imageから作成して接続  
4. Cloud-Init Driveを追加  
5. Boot順序をDiskに  
6. `Convert to Template`

---

## 3. Terraform実行（Phase1）

### 3-1. 事前準備
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` に以下を記入:
- `proxmox_api_token_id`
- `proxmox_api_token_secret`
- `ssh_public_key_path`

### 3-2. apply
```bash
terraform init
terraform apply
```

---

## 4. VM起動確認

- Proxmox UIでVMを確認
- DHCPで付与されたIPを確認
- SSH:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<VM_IP>
```

---

## よくあるエラー

- **権限不足**  
  `permission denied` が出る場合は Role/ACLを再確認

- **ストレージ名不一致**  
  `local-lvm` / `local` が環境と一致しているか

- **ブリッジ名不一致**  
  `vmbr0` 以外なら変数で修正

- **テンプレVMID不一致**  
  `vm_template_id` を修正

- **cloud-initが動かない**  
  テンプレが `Cloud-Init` Drive を持っているか

- **SSH鍵が反映されない**  
  パスが正しいか / 改行が混入していないか

---

## Phase2以降（複数VM展開）

`main.tf` の `count`/`for_each`化で対応可能。  
差分は以下のとおりです。

### Phase2: 複数VM化の手順

1) `terraform.tfvars` に `vm_map` を定義（空ならPhase1の単体VM）

```hcl
vm_map = {
  vm-ubuntu01 = {
    vm_id        = 101
    name         = "vm-ubuntu01"
    cpu_cores    = 2
    memory_mb    = 2048
    disk_gb      = 20
    tags         = ["terraform", "lab"]
    ipv4_address = "dhcp"
  }
  vm-ubuntu02 = {
    vm_id        = 102
    name         = "vm-ubuntu02"
    cpu_cores    = 2
    memory_mb    = 2048
    disk_gb      = 20
    tags         = ["terraform", "lab"]
    ipv4_address = "dhcp"
  }
  vm-ubuntu03 = {
    vm_id        = 103
    name         = "vm-ubuntu03"
    cpu_cores    = 2
    memory_mb    = 2048
    disk_gb      = 20
    tags         = ["terraform", "lab"]
    ipv4_address = "dhcp"
  }
}
```

2) 固定IPにする場合は `ipv4_address` / `ipv4_gateway` を指定

```hcl
ipv4_address = "192.168.1.110/24"
ipv4_gateway = "192.168.1.1"
```

3) そのまま `terraform apply`

```bash
terraform apply
```
