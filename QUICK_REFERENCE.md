# Ansible Playbooks - Quick Reference Guide

## 🚀 Installation

```bash
# macOS
brew install ansible

# Ubuntu/Debian  
sudo apt update && sudo apt install ansible

# RHEL/CentOS
sudo yum install ansible

# Via pip
pip install ansible ansible-lint
```

## 📋 Quick Commands

### List Playbooks
```bash
./scripts/list-playbooks.sh
```

### Validate All
```bash
./scripts/validate-playbooks.sh
```

### Test Connectivity
```bash
ansible all -i inventory/hosts -m ping
```

## 🎯 Basic Playbooks (4)

| Playbook | Command | Description |
|----------|---------|-------------|
| 01-system-update.yml | `./scripts/run-playbook.sh playbooks/basic/01-system-update.yml` | Update packages |
| 02-user-management.yml | `./scripts/run-playbook.sh playbooks/basic/02-user-management.yml` | Manage users |
| 03-file-management.yml | `./scripts/run-playbook.sh playbooks/basic/03-file-management.yml` | File operations |
| 04-service-management.yml | `./scripts/run-playbook.sh playbooks/basic/04-service-management.yml` | Service mgmt |

## 🔧 Intermediate Playbooks (4)

| Playbook | Command | Description |
|----------|---------|-------------|
| 01-apache-webserver.yml | `./scripts/run-playbook.sh -l webservers playbooks/intermediate/01-apache-webserver.yml` | Apache + SSL |
| 02-mysql-database.yml | `./scripts/run-playbook.sh -l databases playbooks/intermediate/02-mysql-database.yml` | MySQL setup |
| 03-docker-setup.yml | `./scripts/run-playbook.sh playbooks/intermediate/03-docker-setup.yml` | Docker install |
| 04-security-hardening.yml | `./scripts/run-playbook.sh playbooks/intermediate/04-security-hardening.yml` | Security |

## 🎓 Advanced Playbooks (4)

| Playbook | Command | Description |
|----------|---------|-------------|
| 01-ha-deployment.yml | `./scripts/run-playbook.sh playbooks/advanced/01-ha-deployment.yml` | HA deploy |
| 02-kubernetes-cluster.yml | `./scripts/run-playbook.sh playbooks/advanced/02-kubernetes-cluster.yml` | K8s cluster |
| 03-monitoring-stack.yml | `./scripts/run-playbook.sh playbooks/advanced/03-monitoring-stack.yml` | Prometheus/Grafana |
| 04-cicd-pipeline.yml | `./scripts/run-playbook.sh playbooks/advanced/04-cicd-pipeline.yml` | Jenkins CI/CD |

## 🛠️ Common Options

```bash
# Dry run (check mode)
./scripts/run-playbook.sh -c <playbook>

# Verbose output
./scripts/run-playbook.sh -vv <playbook>

# Specific hosts
./scripts/run-playbook.sh -l webservers <playbook>

# Extra variables
./scripts/run-playbook.sh -e "var=value" <playbook>

# With tags
./scripts/run-playbook.sh -t tag1,tag2 <playbook>

# Skip tags
./scripts/run-playbook.sh --skip-tags tag1 <playbook>
```

## 📝 Manual Ansible Commands

```bash
# Syntax check
ansible-playbook --syntax-check <playbook>

# Dry run
ansible-playbook --check -i inventory/hosts <playbook>

# Execute
ansible-playbook -i inventory/hosts <playbook>

# Verbose
ansible-playbook -vv -i inventory/hosts <playbook>

# Limit hosts
ansible-playbook -i inventory/hosts -l webservers <playbook>

# Extra vars
ansible-playbook -i inventory/hosts -e "var=value" <playbook>

# Ask for sudo password
ansible-playbook -i inventory/hosts --ask-become-pass <playbook>

# Ask for SSH password
ansible-playbook -i inventory/hosts --ask-pass <playbook>
```

## 🔍 Ad-hoc Commands

```bash
# Ping all hosts
ansible all -i inventory/hosts -m ping

# Check disk space
ansible all -i inventory/hosts -m shell -a "df -h"

# Check uptime
ansible all -i inventory/hosts -m command -a "uptime"

# Install package
ansible all -i inventory/hosts -m package -a "name=vim state=present" --become

# Restart service
ansible all -i inventory/hosts -m service -a "name=httpd state=restarted" --become

# Copy file
ansible all -i inventory/hosts -m copy -a "src=/local/file dest=/remote/file"

# Get facts
ansible all -i inventory/hosts -m setup

# Check service status
ansible all -i inventory/hosts -m service -a "name=httpd" --become
```

## 📂 File Structure

```
ansible-playbooks/
├── ansible.cfg              # Config
├── inventory/              
│   ├── hosts               # Inventory
│   └── group_vars/         # Variables
├── playbooks/
│   ├── basic/              # 4 playbooks
│   ├── intermediate/       # 4 playbooks
│   └── advanced/           # 4 playbooks
├── roles/                  # Reusable roles
├── templates/              # Jinja2 templates
└── scripts/                # Helper scripts
```

## 🔐 Security

```bash
# Encrypt file
ansible-vault encrypt inventory/group_vars/secrets.yml

# Decrypt file
ansible-vault decrypt inventory/group_vars/secrets.yml

# Edit encrypted file
ansible-vault edit inventory/group_vars/secrets.yml

# Run with vault password
ansible-playbook --ask-vault-pass <playbook>

# Use vault password file
ansible-playbook --vault-password-file ~/.vault_pass <playbook>
```

## 🐛 Debugging

```bash
# Syntax check
ansible-playbook --syntax-check <playbook>

# List tasks
ansible-playbook --list-tasks <playbook>

# List tags
ansible-playbook --list-tags <playbook>

# List hosts
ansible-playbook --list-hosts <playbook>

# Step through
ansible-playbook --step <playbook>

# Start at task
ansible-playbook --start-at-task="task name" <playbook>

# Debug mode
ANSIBLE_DEBUG=1 ansible-playbook <playbook>
```

## 📊 Information

```bash
# Ansible version
ansible --version

# List modules
ansible-doc -l

# Module documentation
ansible-doc <module_name>

# List plugins
ansible-doc -t callback -l

# Configuration
ansible-config dump

# Inventory graph
ansible-inventory --graph

# List all hosts
ansible all --list-hosts
```

## 🔄 Common Workflows

### First Time Setup
```bash
1. cd /Users/atul/Downloads/ansible-playbooks
2. vi inventory/hosts              # Update hosts
3. ssh-copy-id user@host           # Setup SSH
4. ansible all -m ping             # Test connectivity
5. ./scripts/validate-playbooks.sh # Validate
```

### Run Basic Setup
```bash
1. ./scripts/run-playbook.sh -c playbooks/basic/01-system-update.yml
2. ./scripts/run-playbook.sh playbooks/basic/01-system-update.yml
3. ./scripts/run-playbook.sh playbooks/basic/04-service-management.yml
```

### Deploy Web Server
```bash
1. vi inventory/group_vars/webservers.yml  # Configure
2. ./scripts/run-playbook.sh -c -l webservers playbooks/intermediate/01-apache-webserver.yml
3. ./scripts/run-playbook.sh -l webservers playbooks/intermediate/01-apache-webserver.yml
4. curl http://web-server-ip              # Verify
```

### Setup Monitoring
```bash
1. ./scripts/run-playbook.sh -c playbooks/advanced/03-monitoring-stack.yml
2. ./scripts/run-playbook.sh playbooks/advanced/03-monitoring-stack.yml
3. # Access Prometheus: http://server:9090
4. # Access Grafana: http://server:3000
```

## ⚡ Performance Tips

```bash
# Enable pipelining (in ansible.cfg)
pipelining = True

# Increase forks
ansible-playbook -f 10 <playbook>

# Use strategy
strategy: free

# Fact caching (already configured)
gathering = smart
fact_caching = jsonfile
```

## 🎯 Best Practices

1. **Always test in check mode first**
   ```bash
   ./scripts/run-playbook.sh -c <playbook>
   ```

2. **Use version control**
   ```bash
   git add . && git commit -m "message"
   ```

3. **Keep secrets encrypted**
   ```bash
   ansible-vault encrypt secrets.yml
   ```

4. **Document variables**
   - Add comments in group_vars files

5. **Use roles for reusability**
   - See roles/common/ example

6. **Tag your tasks**
   ```yaml
   tags: [configuration, deployment]
   ```

7. **Make playbooks idempotent**
   - Run multiple times = same result

8. **Test on staging first**
   - Use separate inventory files

## 📞 Quick Help

```bash
# Script help
./scripts/run-playbook.sh --help

# Ansible help
ansible-playbook --help

# Module documentation
ansible-doc <module_name>

# Example: copy module
ansible-doc copy
```

## 🔗 Quick Links

- **Main Docs**: README.md
- **Testing Guide**: TESTING.md
- **Project Summary**: PROJECT_SUMMARY.md
- **Ansible Docs**: https://docs.ansible.com/

## 📈 Suggested Learning Order

1. Basic/01-system-update.yml ⭐
2. Basic/02-user-management.yml ⭐
3. Basic/03-file-management.yml ⭐
4. Basic/04-service-management.yml ⭐
5. Intermediate/01-apache-webserver.yml ⭐⭐
6. Intermediate/02-mysql-database.yml ⭐⭐
7. Intermediate/03-docker-setup.yml ⭐⭐
8. Intermediate/04-security-hardening.yml ⭐⭐
9. Advanced/01-ha-deployment.yml ⭐⭐⭐
10. Advanced/03-monitoring-stack.yml ⭐⭐⭐
11. Advanced/02-kubernetes-cluster.yml ⭐⭐⭐
12. Advanced/04-cicd-pipeline.yml ⭐⭐⭐

---

**Keep this file handy for quick reference!** 🚀
