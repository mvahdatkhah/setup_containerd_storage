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
[kubemasters_nodes]
kubemaster1 ansible_host=192.168.1.101
kubemaster1 ansible_host=192.168.1.102
kubemaster1 ansible_host=192.168.1.103

[kubenodes_nodes]
kubenode1 ansible_host=192.168.1.103
kubenode2 ansible_host=192.168.1.104
kubenode3 ansible_host=192.168.1.105

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

⚙️ What This Role Does

✅ Wipes existing partition table on /dev/sdb
✅ Creates 4 partitions using parted
✅ Initializes /dev/sdb1 as a physical volume
✅ Creates a volume group and logical volume
✅ Formats with ext4
✅ Mounts to /var/lib/containerd
✅ Adds an entry to /etc/fstab for persistence


🧪 Safety Notes

⚠️ This role will destroy all data on /dev/sdb.
✅ Only run this on fresh/unused disks in controlled environments.
✅ Always test in staging or virtual machines before production.

📜 License

MIT © 2025 Your Name
🤝 Contributing

Pull requests, issues, and suggestions are always welcome!

🧭 Future Improvements

✅ Add support for XFS and BTRFS filesystems
✅ Molecule testing with Vagrant or Docker
✅ GitHub Actions integration for linting and CI

```bash
Let me know if you'd like me to:

- Add a sample `.gitignore`, `ansible.cfg`, or GitHub Actions workflow
- Rename the role or script for consistency across your repo
- Include versioning or changelog sections for release tracking
```    








