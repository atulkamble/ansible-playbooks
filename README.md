# 🚀 **ANSIBLE PLAYBOOKS — COMPLETE & ORGANIZED**

**Basic → Intermediate → Advanced (AWS, Linux, Docker, Security, Kubernetes)**

---

# 1️⃣ **BASIC PLAYBOOKS (1–20)**

Fundamental operations, ideal for beginners.

---

## **1. Ping All Hosts**

```yaml
- hosts: all
  tasks:
    - ansible.builtin.ping:
```

---

## **2. Print Message**

```yaml
- hosts: all
  tasks:
    - debug:
        msg: "Hello from Ansible!"
```

---

## **3. Check Uptime**

```yaml
- hosts: all
  tasks:
    - shell: uptime
      register: out
    - debug:
        var: out.stdout
```

---

## **4. List Files in /etc**

```yaml
- hosts: all
  tasks:
    - shell: ls -l /etc
      register: out
    - debug:
        var: out.stdout_lines
```

---

## **5. Create File**

```yaml
- hosts: all
  become: yes
  tasks:
    - file:
        path: /tmp/ansible_test.txt
        state: touch
```

---

## **6. Write Content into File**

```yaml
- hosts: all
  become: yes
  tasks:
    - copy:
        dest: /tmp/message.txt
        content: "This file was created using Ansible!"
```

---

## **7. Create Directory**

```yaml
- hosts: all
  become: yes
  tasks:
    - file:
        path: /tmp/demo
        state: directory
        mode: '0755'
```

---

## **8. Remove a File**

```yaml
- hosts: all
  become: yes
  tasks:
    - file:
        path: /tmp/ansible_test.txt
        state: absent
```

---

## **9. Install Package (tree)**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum:
        name: tree
        state: present
```

---

## **10. Remove Package**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum:
        name: tree
        state: absent
```

---

## **11. Start Service**

```yaml
- hosts: all
  become: yes
  tasks:
    - service:
        name: crond
        state: started
```

---

## **12. Stop Service**

```yaml
- hosts: all
  become: yes
  tasks:
    - service:
        name: crond
        state: stopped
```

---

## **13. Add a User**

```yaml
- hosts: all
  become: yes
  tasks:
    - user:
        name: student
        state: present
```

---

## **14. Delete a User**

```yaml
- hosts: all
  become: yes
  tasks:
    - user:
        name: student
        state: absent
```

---

## **15. Install Package via Variable**

```yaml
- hosts: all
  become: yes
  vars:
    pkg: httpd
  tasks:
    - yum:
        name: "{{ pkg }}"
        state: present
```

---

## **16. Display Hostname**

```yaml
- hosts: all
  tasks:
    - debug:
        msg: "Hostname: {{ inventory_hostname }}"
```

---

## **17. Loop – Create Multiple Files**

```yaml
- hosts: all
  become: yes
  tasks:
    - file:
        path: "/tmp/{{ item }}"
        state: touch
      loop:
        - f1.txt
        - f2.txt
        - f3.txt
```

---

## **18. Check Memory (free -h)**

```yaml
- hosts: all
  tasks:
    - shell: free -h
      register: mem
    - debug:
        var: mem.stdout_lines
```

---

## **19. Check OS Version**

```yaml
- hosts: all
  tasks:
    - debug:
        var: ansible_facts['distribution']
```

---

## **20. Template Example**

`play.yml`

```yaml
- hosts: all
  become: yes
  tasks:
    - template:
        src: templates/message.j2
        dest: /tmp/message.txt
```

`templates/message.j2`

```
Hello from Ansible.
Hostname: {{ ansible_hostname }}
IP: {{ ansible_default_ipv4.address }}
```

---

# 2️⃣ **INTERMEDIATE PLAYBOOKS (21–30)**

---

## **21. Install Multiple Packages**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum:
        name: [git, tree, curl]
        state: present
```

---

## **22. Create Multiple Users**

```yaml
- hosts: all
  become: yes
  vars:
    users: [dev1, dev2, dev3]
  tasks:
    - user:
        name: "{{ item }}"
      loop: "{{ users }}"
```

---

## **23. Update All Packages**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum:
        name: '*'
        state: latest
```

---

## **24. Create Directory Structure**

```yaml
- hosts: all
  become: yes
  tasks:
    - file:
        path: "/opt/app/{{ item }}"
        state: directory
      loop:
        - logs
        - config
        - backups
```

---

## **25. Delete Logs Older Than 7 Days**

```yaml
- hosts: all
  become: yes
  tasks:
    - find:
        paths: /var/log
        age: 7d
        recurse: yes
      register: old_logs

    - file:
        path: "{{ item.path }}"
        state: absent
      loop: "{{ old_logs.files }}"
```

---

## **26. Install & Configure Chrony**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum: { name: chrony, state: present }
    - systemd: { name: chronyd, state: started, enabled: yes }
```

---

## **27. sysctl Tuning**

```yaml
- hosts: all
  become: yes
  vars:
    sysctl_values:
      net.ipv4.ip_forward: 1
      vm.swappiness: 10
  tasks:
    - sysctl:
        name: "{{ item.key }}"
        value: "{{ item.value }}"
      loop: "{{ sysctl_values | dict2items }}"
```

---

## **28. Add a Cron Job**

```yaml
- hosts: all
  become: yes
  tasks:
    - cron:
        name: "Daily Backup"
        minute: "0"
        hour: "1"
        job: "/usr/bin/rsync -av /data /backup"
```

---

## **29. Replace Text in File**

```yaml
- hosts: all
  become: yes
  tasks:
    - replace:
        path: /etc/myapp/config.conf
        regexp: "127.0.0.1"
        replace: "192.168.1.50"
```

---

## **30. Configure Firewalld**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum: { name: firewalld, state: present }
    - systemd: { name: firewalld, state: started, enabled: yes }
    - firewalld:
        port: 8080/tcp
        permanent: yes
        state: enabled
    - firewalld:
        state: reloaded
        immediate: yes
```

---

# 3️⃣ **ADVANCED PLAYBOOKS (31–42)**

Cloud, Docker, Jenkins, HAProxy, Security, Kubernetes.

---

## **31. Install Docker (Amazon Linux / RHEL)**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum: { name: docker, state: present }
    - systemd: { name: docker, state: started, enabled: yes }
    - user:
        name: ec2-user
        groups: docker
        append: yes
```

---

## **32. Install Jenkins**

```yaml
- hosts: jenkins
  become: yes
  tasks:
    - yum: { name: java-11-openjdk, state: present }
    - get_url:
        url: https://pkg.jenkins.io/redhat-stable/jenkins.repo
        dest: /etc/yum.repos.d/jenkins.repo
    - rpm_key:
        state: present
        key: https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    - yum: { name: jenkins, state: present }
    - systemd: { name: jenkins, state: started, enabled: yes }
```

---

## **33. Configure Nginx Load Balancer**

```yaml
- hosts: lb
  become: yes
  vars:
    backends:
      - 192.168.1.10
      - 192.168.1.20
  tasks:
    - yum: { name: nginx, state: present }
    - template:
        src: templates/lb.conf.j2
        dest: /etc/nginx/conf.d/lb.conf
    - systemd: { name: nginx, state: restarted }
```

---

## **34. Install & Configure HAProxy**

```yaml
- hosts: lb
  become: yes
  tasks:
    - yum: { name: haproxy, state: present }
    - copy:
        dest: /etc/haproxy/haproxy.cfg
        content: |
          frontend http_front
            bind *:80
            default_backend http_back
          backend http_back
            balance roundrobin
            server web1 192.168.1.10:80
            server web2 192.168.1.11:80
    - systemd: { name: haproxy, state: restarted }
```

---

## **35. Install MySQL Server**

```yaml
- hosts: db
  become: yes
  tasks:
    - yum: { name: mariadb-server, state: present }
    - systemd: { name: mariadb, state: started, enabled: yes }
```

---

## **36. Create MySQL DB + User**

```yaml
- hosts: db
  become: yes
  vars:
    db: devopsdb
    user: devops
    pass: DevOps@123
  tasks:
    - mysql_db:
        name: "{{ db }}"
        state: present
    - mysql_user:
        name: "{{ user }}"
        password: "{{ pass }}"
        priv: "{{ db }}.*:ALL"
        state: present
```

---

## **37. Add SSH Key to ec2-user**

```yaml
- hosts: amazon_linux
  become: yes
  vars:
    sshkey: "ssh-rsa AAA..."
  tasks:
    - authorized_key:
        user: ec2-user
        key: "{{ sshkey }}"
```

---

## **38. Mount EBS Volume**

```yaml
- hosts: amazon_linux
  become: yes
  vars:
    device: /dev/xvdf
    mountp: /mnt/data
  tasks:
    - filesystem:
        fstype: ext4
        dev: "{{ device }}"
    - file:
        path: "{{ mountp }}"
        state: directory
    - mount:
        path: "{{ mountp }}"
        src: "{{ device }}"
        fstype: ext4
        state: mounted
```

---

## **39. Install Fail2Ban**

```yaml
- hosts: all
  become: yes
  tasks:
    - yum: { name: epel-release, state: present }
    - yum: { name: fail2ban, state: present }
    - systemd: { name: fail2ban, state: started, enabled: yes }
```

---

## **40. Install Prometheus Node Exporter**

```yaml
- hosts: all
  become: yes
  tasks:
    - get_url:
        url: https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
        dest: /tmp/ne.tar.gz
    - unarchive:
        src: /tmp/ne.tar.gz
        dest: /opt/
        remote_src: yes
    - copy:
        dest: /etc/systemd/system/node_exporter.service
        content: |
          [Service]
          ExecStart=/opt/node_exporter-1.3.1.linux-amd64/node_exporter
    - systemd:
        name: node_exporter
        state: started
        enabled: yes
```

---

## **41. Install kubectl (Kubernetes CLI)**

```yaml
- hosts: all
  become: yes
  tasks:
    - get_url:
        url: https://storage.googleapis.com/kubernetes-release/release/v1.27.0/bin/linux/amd64/kubectl
        dest: /usr/local/bin/kubectl
        mode: '0755'
```

---

## **42. Create Kubernetes Namespace + Pod**

```yaml
- hosts: localhost
  tasks:
    - kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Namespace
          metadata:
            name: devops
```

```yaml
- hosts: localhost
  tasks:
    - kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Pod
          metadata:
            name: nginx-pod
            namespace: devops
          spec:
            containers:
              - name: nginx
                image: nginx
```

---

