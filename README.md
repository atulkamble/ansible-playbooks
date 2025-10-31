# Ansible Playbooks Collection

A comprehensive collection of Ansible playbooks ranging from basic to advanced configurations for infrastructure automation.

## 📁 Repository Structure

```
ansible-playbooks/
├── ansible.cfg                 # Ansible configuration
├── inventory/                  # Inventory files
│   ├── hosts                  # Main inventory
│   └── group_vars/            # Group variables
│       ├── all.yml
│       ├── webservers.yml
│       └── databases.yml
├── playbooks/                 # Playbook collection
│   ├── basic/                 # Basic playbooks
│   ├── intermediate/          # Intermediate playbooks
│   └── advanced/              # Advanced playbooks
├── roles/                     # Ansible roles
│   └── common/
├── templates/                 # Jinja2 templates
├── files/                     # Static files
└── scripts/                   # Utility scripts
    ├── validate-playbooks.sh  # Validation script
    ├── run-playbook.sh        # Playbook runner
    └── list-playbooks.sh      # List all playbooks
```

## 🚀 Quick Start

### Prerequisites

- Ansible 2.9 or higher
- Python 3.6 or higher
- SSH access to target hosts

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/ansible-playbooks.git
cd ansible-playbooks
```

2. **Install Ansible:**
```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# RHEL/CentOS
sudo yum install ansible

# Using pip
pip install ansible
```

3. **Install ansible-lint (optional but recommended):**
```bash
pip install ansible-lint
```

4. **Make scripts executable:**
```bash
chmod +x scripts/*.sh
```

### Configuration

1. **Update inventory file:**
Edit `inventory/hosts` with your server details:
```ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[databases]
db1 ansible_host=192.168.1.20
```

2. **Update group variables:**
Edit files in `inventory/group_vars/` as needed.

3. **Configure SSH access:**
```bash
ssh-copy-id user@your-server
        enabled: true

    - name: Deploy index.html
      copy:
        content: "<h1>Hello from Ansible on Amazon Linux</h1>"
        dest: /var/www/html/index.html
        mode: '0644'
```

---

## 3. **EC2-Specific: Add SSH Key to EC2 User**

```yaml
---
- name: Add SSH public key to ec2-user
  hosts: amazon_linux
  become: true

  vars:
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3..."

  tasks:
    - name: Ensure .ssh directory exists
      file:
        path: /home/ec2-user/.ssh
        state: directory
        mode: '0700'
        owner: ec2-user
        group: ec2-user

    - name: Add SSH key to authorized_keys
      authorized_key:
        user: ec2-user
        key: "{{ ssh_public_key }}"
```

---

## 4. **Docker Installation on Amazon Linux 2**

```yaml
---
- name: Install Docker on Amazon Linux 2
  hosts: all
  become: true

  tasks:
    - name: Install Docker package
      yum:
        name: docker
        state: present

    - name: Start and enable Docker service
      systemd:
        name: docker
        state: started
        enabled: true

    - name: Add ec2-user to docker group
      user:
        name: ec2-user
        groups: docker
        append: yes
```

---

## 5. **Custom Yum Repo and Package Installation**

```yaml
---
- name: Add custom Yum repo and install package
  hosts: amazon_linux
  become: true

  tasks:
    - name: Add custom repository
      yum_repository:
        name: custom-repo
        description: Custom YUM Repo
        baseurl: http://repo.example.com/yum
        enabled: yes
        gpgcheck: no

    - name: Install package from custom repo
      yum:
        name: custom-package
        state: present
```

---

## 6. **Nginx Installation & Reverse Proxy Configuration**

```yaml
---
- name: Install and configure Nginx as reverse proxy
  hosts: all
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Start and enable Nginx
      systemd:
        name: nginx
        state: started
        enabled: true

    - name: Configure Nginx reverse proxy
      copy:
        dest: /etc/nginx/conf.d/reverse-proxy.conf
        content: |
          server {
              listen 80;
              location / {
                  proxy_pass http://localhost:5000;
              }
          }

    - name: Restart Nginx to apply config
      systemd:
        name: nginx
        state: restarted
```

---

## 7. **Create Users & Add to Sudoers**

```yaml
---
- name: Create user and configure sudo access
  hosts: amazon_linux
  become: true

  vars:
    new_user: devopsadmin

  tasks:
    - name: Create a new user
      user:
        name: "{{ new_user }}"
        shell: /bin/bash
        create_home: yes

    - name: Add user to wheel group (sudoers)
      user:
        name: "{{ new_user }}"
        groups: wheel
        append: yes

    - name: Set authorized key for SSH access
      authorized_key:
        user: "{{ new_user }}"
        key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD..."
```

---

## 8. **Install Python3 and Pip**

```yaml
---
- name: Install Python3 and pip on Amazon Linux
  hosts: all
  become: true

  tasks:
    - name: Install Python3
      yum:
        name: python3
        state: present

    - name: Install pip3
      command: python3 -m ensurepip
      args:
        creates: /usr/local/bin/pip3
```

---

## 9. **Mount EBS Volume to Amazon Linux**

```yaml
---
- name: Format and mount EBS volume
  hosts: amazon_linux
  become: true

  vars:
    device_name: /dev/xvdf
    mount_point: /mnt/data

  tasks:
    - name: Create filesystem on the EBS volume
      filesystem:
        fstype: ext4
        dev: "{{ device_name }}"
      when: device_name is defined

    - name: Create mount point directory
      file:
        path: "{{ mount_point }}"
        state: directory

    - name: Mount the EBS volume
      mount:
        path: "{{ mount_point }}"
        src: "{{ device_name }}"
        fstype: ext4
        state: mounted

    - name: Persist mount in fstab
      mount:
        path: "{{ mount_point }}"
        src: "{{ device_name }}"
        fstype: ext4
        opts: defaults
        state: present
```

---

## 10. **Fail2Ban Installation for Security**

```yaml
---
- name: Install and configure Fail2Ban on Amazon Linux
  hosts: amazon_linux
  become: true

  tasks:
    - name: Install EPEL repository (needed for fail2ban)
      yum:
        name: epel-release
        state: present

    - name: Install fail2ban
      yum:
        name: fail2ban
        state: present

    - name: Start and enable fail2ban
      systemd:
        name: fail2ban
        state: started
        enabled: true

    - name: Deploy fail2ban jail configuration
      copy:
        dest: /etc/fail2ban/jail.local
        content: |
          [sshd]
          enabled = true
          port    = ssh
          logpath = /var/log/secure
          maxretry = 5
```

---

## 11. **Prometheus Node Exporter Setup**

```yaml
---
- name: Install Prometheus Node Exporter on Amazon Linux
  hosts: amazon_linux
  become: true

  tasks:
    - name: Download node exporter binary
      get_url:
        url: https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
        dest: /tmp/node_exporter.tar.gz

    - name: Extract node exporter
      unarchive:
        src: /tmp/node_exporter.tar.gz
        dest: /opt/
        remote_src: yes

    - name: Create systemd service for node exporter
      copy:
        dest: /etc/systemd/system/node_exporter.service
        content: |
          [Unit]
          Description=Node Exporter
          After=network.target

          [Service]
          User=nobody
          ExecStart=/opt/node_exporter-1.3.1.linux-amd64/node_exporter

          [Install]
          WantedBy=default.target

    - name: Start and enable node exporter
      systemd:
        name: node_exporter
        state: started
        enabled: true
```

---

## 12. **UFW (Firewall) Configuration Example**

```yaml
---
- name: Install and configure UFW firewall on Amazon Linux
  hosts: amazon_linux
  become: true

  tasks:
    - name: Install UFW
      yum:
        name: ufw
        state: present

    - name: Allow SSH
      ufw:
        rule: allow
        name: OpenSSH

    - name: Allow HTTP
      ufw:
        rule: allow
        port: '80'

    - name: Enable UFW
      ufw:
        state: enabled
        direction: incoming
        policy: deny
```

---

## Inventory File Example (`hosts`)

```ini
[amazon_linux]
ec2-54-123-45-67.compute-1.amazonaws.com ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/my-key.pem
```

---

## Run Command

```bash
ansible-playbook -i hosts playbook.yml
```

Here’s a **collection of basic Ansible YAML playbooks** that you can directly use for learning, practice, or automation labs 👇

---

## 🧩 **1. Basic Ping Playbook**

Checks connectivity to managed nodes.

```yaml
---
- name: Ping all hosts
  hosts: all
  tasks:
    - name: Test connectivity
      ansible.builtin.ping:
```

---

## ⚙️ **2. Install a Package**

Installs Apache (httpd) on RedHat-based systems.

```yaml
---
- name: Install Apache Web Server
  hosts: webservers
  become: yes
  tasks:
    - name: Install httpd
      ansible.builtin.yum:
        name: httpd
        state: present
```

---

## 🧰 **3. Start & Enable Service**

```yaml
---
- name: Ensure Apache is started and enabled
  hosts: webservers
  become: yes
  tasks:
    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: yes
```

---

## 📄 **4. Copy a File to Remote Server**

```yaml
---
- name: Copy index.html to webservers
  hosts: webservers
  become: yes
  tasks:
    - name: Copy file
      ansible.builtin.copy:
        src: files/index.html
        dest: /var/www/html/index.html
        owner: root
        group: root
        mode: '0644'
```

---

## 🔧 **5. Create a User**

```yaml
---
- name: Create a new user
  hosts: all
  become: yes
  tasks:
    - name: Add devops user
      ansible.builtin.user:
        name: devops
        state: present
        groups: wheel
```

---

## 🧹 **6. Remove a Package**

```yaml
---
- name: Remove Apache Web Server
  hosts: webservers
  become: yes
  tasks:
    - name: Remove httpd
      ansible.builtin.yum:
        name: httpd
        state: absent
```

---

## 🧾 **7. Gather Facts**

```yaml
---
- name: Display system facts
  hosts: all
  tasks:
    - name: Print OS details
      ansible.builtin.debug:
        var: ansible_facts['os_family']
```

---

## 🔄 **8. Restart Service**

```yaml
---
- name: Restart Apache
  hosts: webservers
  become: yes
  tasks:
    - name: Restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted
```

---

## 🌐 **9. Deploy Simple Web Page**

Combines multiple tasks (install, copy, start service).

```yaml
---
- name: Deploy a simple web page
  hosts: webservers
  become: yes
  tasks:
    - name: Install Apache
      ansible.builtin.yum:
        name: httpd
        state: present

    - name: Copy index file
      ansible.builtin.copy:
        src: files/index.html
        dest: /var/www/html/index.html

    - name: Start and enable service
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: yes
```

---

## 🗂 **10. Template Example**

Using Jinja2 template for dynamic content.

```yaml
---
- name: Deploy a template file
  hosts: webservers
  become: yes
  tasks:
    - name: Copy template
      ansible.builtin.template:
        src: templates/index.j2
        dest: /var/www/html/index.html
```

**Example template (`templates/index.j2`):**

```jinja2
<html>
  <body>
    <h1>Welcome to {{ ansible_hostname }}</h1>
    <p>Server IP: {{ ansible_default_ipv4.address }}</p>
  </body>
</html>
```

---

## 📦 **11. Install Multiple Packages**

```yaml
---
- name: Install multiple packages
  hosts: all
  become: yes
  tasks:
    - name: Install git, tree, and curl
      ansible.builtin.yum:
        name:
          - git
          - tree
          - curl
        state: present
```

---

## 🧮 **12. Use Variables**

```yaml
---
- name: Install package using variables
  hosts: all
  become: yes
  vars:
    pkg_name: httpd
  tasks:
    - name: Install {{ pkg_name }}
      ansible.builtin.yum:
        name: "{{ pkg_name }}"
        state: present
```

---

Would you like me to create a **GitHub-ready structure** (with `inventory`, `files/`, `templates/`, and `site.yml`) containing these 10+ playbooks as examples for your students or project repo (e.g., `ansible-basic-lab`)?

---
