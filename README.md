# 🐳 setup_containerd_storage - Ansible Role Project

This project contains an Ansible role that automates the setup of storage for `containerd` using LVM on `/dev/sdb`. It handles disk partitioning, volume group and logical volume creation, filesystem formatting, and mounting.

> ⚠️ WARNING: This will modify `/dev/sdb` on your hosts. It will delete existing partitions and data!

---

## 📁 Directory Structure

```bash
roles/setup_containerd_storage/
├── defaults
│   └── main.yml                  # Default variables (overridable)
├── files
│   └── setup_containerd_storage.sh  # Core bash script for storage setup
├── handlers
│   └── main.yml                  # (Empty, placeholder)
├── meta
│   └── main.yml                  # Role metadata
├── tasks
│   └── main.yml                  # Executes the bash script
├── templates                     # (Empty, placeholder)
└── vars
    └── main.yml                  # Static, internal variables
```

🚀 Getting Started from Scratch

Follow these steps to set up and run the project on your infrastructure.

1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/setup_containerd_storage.git
cd setup_containerd_storage
```

2️⃣ Create Your Inventory File

Create a basic Ansible inventory file inventory.ini:

```bash
[kubernetes_nodes]
kubenode1 ansible_host=192.168.1.101
kubenode2 ansible_host=192.168.1.102
kubenode3 ansible_host=192.168.1.103

[all:vars]
ansible_user=your_ssh_user
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

3️⃣ Customize Variables (Optional)

Open roles/setup_containerd_storage/defaults/main.yml and adjust as needed:

```bash
disk: /dev/sdb
vg_name: vg_containerd
lv_name: lv_containerd
mount_point: /var/lib/containerd
filesystem_type: ext4
```

Partition layout is in vars/main.yml:

```bash
partitions:
  - { num: 1, start: "1MB", end: "87GB" }
  - { num: 2, start: "87GB", end: "175GB" }
  - { num: 3, start: "175GB", end: "262GB" }
  - { num: 4, start: "262GB", end: "350GB" }
```

4️⃣ Create Your Playbook

Create site.yml at the root of the repo:

```bash
---
- name: Setup containerd storage
  hosts: kubernetes_nodes
  become: true
  roles:
    - role: setup_containerd_storage
      tags: [setup_storage]
```

5️⃣ Run the Playbook 🎯

```bash
ansible-playbook -i inventory.ini site.yml --tags setup_storage
```

⚙️ What It Does

    Wipes existing partitions on /dev/sdb

    Creates 4 primary partitions

    Creates a volume group on /dev/sdb1

    Creates a logical volume using all VG free space

    Formats it with ext4

    Mounts it to /var/lib/containerd

    Persists the mount using /etc/fstab

🧪 Safety Notes

    Only use on dedicated, unused disks (like /dev/sdb)

    Never run on production hosts without full backups

    Test in a lab or VM environment first    

📜 License

MIT © 2025 Your Name
🤝 Contributing

Pull requests, issues, and suggestions are always welcome!
🧭 Future Plans

    Add support for other filesystems (xfs, btrfs)

    Make the role idempotent and test with Molecule

    Add GitHub Actions CI for Ansible lint & syntax checks

```bash

---

Let me know if you want the full GitHub-ready repo boilerplate (`.gitignore`, `requirements.yml`, `ansible.cfg`, etc.).
```    








