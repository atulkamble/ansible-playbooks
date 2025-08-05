**starter collection of Ansible Playbook templates for Amazon Linux hosts**, covering common scenarios like **package installation, service management, file configuration, and EC2-specific tasks**.

---

## 1. **Basic Setup: Update & Install Packages**

```yaml
---
- name: Basic setup for Amazon Linux
  hosts: all
  become: true

  tasks:
    - name: Update all packages
      yum:
        name: '*'
        state: latest

    - name: Install essential packages
      yum:
        name:
          - git
          - wget
          - unzip
          - tree
        state: present
```

---

## 2. **Apache Web Server Deployment**

```yaml
---
- name: Install and configure Apache on Amazon Linux
  hosts: amazon_linux
  become: true

  tasks:
    - name: Install Apache (httpd)
      yum:
        name: httpd
        state: present

    - name: Start and enable Apache service
      systemd:
        name: httpd
        state: started
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
  hosts: amazon_linux
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
  hosts: amazon_linux
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
  hosts: amazon_linux
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

---
