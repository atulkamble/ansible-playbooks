# Ansible Playbooks Testing Guide

## Installation Requirements

Before using these playbooks, you need to install Ansible:

### macOS
```bash
brew install ansible
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install ansible python3-pip
pip3 install ansible-lint
```

### RHEL/CentOS/Amazon Linux
```bash
sudo yum install epel-release
sudo yum install ansible
pip3 install ansible-lint
```

### Using Python pip
```bash
pip3 install ansible ansible-lint
```

## Verification

After installation, verify with:
```bash
ansible --version
ansible-playbook --version
ansible-lint --version
```

## Validation Steps

### 1. Syntax Check All Playbooks

Run the validation script:
```bash
cd /Users/atul/Downloads/ansible-playbooks
./scripts/validate-playbooks.sh
```

This will:
- Check syntax for all playbooks
- Run ansible-lint (if installed)
- Perform dry-run checks
- Generate a summary report

### 2. Manual Syntax Check

Check individual playbooks:
```bash
# Basic playbooks
ansible-playbook --syntax-check playbooks/basic/01-system-update.yml
ansible-playbook --syntax-check playbooks/basic/02-user-management.yml
ansible-playbook --syntax-check playbooks/basic/03-file-management.yml
ansible-playbook --syntax-check playbooks/basic/04-service-management.yml

# Intermediate playbooks
ansible-playbook --syntax-check playbooks/intermediate/01-apache-webserver.yml
ansible-playbook --syntax-check playbooks/intermediate/02-mysql-database.yml
ansible-playbook --syntax-check playbooks/intermediate/03-docker-setup.yml
ansible-playbook --syntax-check playbooks/intermediate/04-security-hardening.yml

# Advanced playbooks
ansible-playbook --syntax-check playbooks/advanced/01-ha-deployment.yml
ansible-playbook --syntax-check playbooks/advanced/02-kubernetes-cluster.yml
ansible-playbook --syntax-check playbooks/advanced/03-monitoring-stack.yml
ansible-playbook --syntax-check playbooks/advanced/04-cicd-pipeline.yml
```

### 3. Lint Check

```bash
ansible-lint playbooks/basic/*.yml
ansible-lint playbooks/intermediate/*.yml
ansible-lint playbooks/advanced/*.yml
```

### 4. Dry Run (Check Mode)

Test without making changes:
```bash
ansible-playbook --check -i inventory/hosts playbooks/basic/01-system-update.yml
```

## Testing Workflow

### Step 1: Set Up Test Environment

1. **Update inventory:**
```bash
vi inventory/hosts
```

2. **Configure SSH access:**
```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id user@target-host
```

3. **Test connectivity:**
```bash
ansible all -i inventory/hosts -m ping
```

### Step 2: Test Basic Playbooks

Start with basic playbooks on a test system:

```bash
# System update (dry run first)
./scripts/run-playbook.sh -c playbooks/basic/01-system-update.yml

# If dry run looks good, execute
./scripts/run-playbook.sh playbooks/basic/01-system-update.yml

# User management
./scripts/run-playbook.sh -c playbooks/basic/02-user-management.yml
./scripts/run-playbook.sh playbooks/basic/02-user-management.yml

# File management
./scripts/run-playbook.sh -c playbooks/basic/03-file-management.yml
./scripts/run-playbook.sh playbooks/basic/03-file-management.yml

# Service management
./scripts/run-playbook.sh -c playbooks/basic/04-service-management.yml
./scripts/run-playbook.sh playbooks/basic/04-service-management.yml
```

### Step 3: Test Intermediate Playbooks

```bash
# Apache web server
./scripts/run-playbook.sh -c -l webservers playbooks/intermediate/01-apache-webserver.yml
./scripts/run-playbook.sh -l webservers playbooks/intermediate/01-apache-webserver.yml

# MySQL database
./scripts/run-playbook.sh -c -l databases playbooks/intermediate/02-mysql-database.yml
./scripts/run-playbook.sh -l databases playbooks/intermediate/02-mysql-database.yml

# Docker setup
./scripts/run-playbook.sh -c playbooks/intermediate/03-docker-setup.yml
./scripts/run-playbook.sh playbooks/intermediate/03-docker-setup.yml

# Security hardening
./scripts/run-playbook.sh -c playbooks/intermediate/04-security-hardening.yml
./scripts/run-playbook.sh playbooks/intermediate/04-security-hardening.yml
```

### Step 4: Test Advanced Playbooks

**Warning:** Test advanced playbooks in a controlled environment first!

```bash
# HA Deployment
./scripts/run-playbook.sh -c playbooks/advanced/01-ha-deployment.yml
./scripts/run-playbook.sh playbooks/advanced/01-ha-deployment.yml

# Kubernetes cluster (requires multiple nodes)
./scripts/run-playbook.sh -c playbooks/advanced/02-kubernetes-cluster.yml
./scripts/run-playbook.sh playbooks/advanced/02-kubernetes-cluster.yml

# Monitoring stack
./scripts/run-playbook.sh -c playbooks/advanced/03-monitoring-stack.yml
./scripts/run-playbook.sh playbooks/advanced/03-monitoring-stack.yml

# CI/CD pipeline
./scripts/run-playbook.sh -c playbooks/advanced/04-cicd-pipeline.yml
./scripts/run-playbook.sh playbooks/advanced/04-cicd-pipeline.yml
```

## Common Testing Scenarios

### Test on Localhost

```bash
# Run against local machine
ansible-playbook -i "localhost," -c local playbooks/basic/01-system-update.yml
```

### Test with Verbose Output

```bash
# Minimal verbosity
./scripts/run-playbook.sh -v playbooks/basic/01-system-update.yml

# More verbose
./scripts/run-playbook.sh -vv playbooks/basic/01-system-update.yml

# Maximum verbosity
./scripts/run-playbook.sh -vvv playbooks/basic/01-system-update.yml
```

### Test with Extra Variables

```bash
./scripts/run-playbook.sh \
  -e "domain_name=test.local" \
  -e "server_admin=admin@test.local" \
  playbooks/intermediate/01-apache-webserver.yml
```

### Test Specific Tags

```bash
# Run only configuration tasks
./scripts/run-playbook.sh -t configuration playbooks/intermediate/01-apache-webserver.yml

# Skip certain tags
./scripts/run-playbook.sh --skip-tags firewall playbooks/intermediate/04-security-hardening.yml
```

## Expected Results

### Basic Playbooks
- ✅ All packages updated
- ✅ Users created with SSH access
- ✅ Directories and files created
- ✅ Services installed and running

### Intermediate Playbooks
- ✅ Apache serving on port 80/443
- ✅ MySQL databases created
- ✅ Docker containers running
- ✅ Firewall rules applied

### Advanced Playbooks
- ✅ Applications deployed with zero downtime
- ✅ Kubernetes cluster operational
- ✅ Prometheus/Grafana accessible
- ✅ Jenkins pipeline configured

## Troubleshooting

### Connection Issues
```bash
# Test SSH connectivity
ansible all -i inventory/hosts -m ping

# Test with different user
ansible all -i inventory/hosts -m ping -u ubuntu

# Use password authentication
ansible all -i inventory/hosts -m ping --ask-pass
```

### Permission Issues
```bash
# Test sudo access
ansible all -i inventory/hosts -m shell -a "whoami" --become

# Use password for sudo
ansible-playbook playbooks/basic/01-system-update.yml --ask-become-pass
```

### Python Interpreter Issues
```bash
# Set Python path in inventory
echo "ansible_python_interpreter=/usr/bin/python3" >> inventory/group_vars/all.yml
```

## Cleanup

After testing, you may want to clean up:

```bash
# Remove test users
ansible all -i inventory/hosts -m user -a "name=testuser state=absent remove=yes" --become

# Stop test services
ansible all -i inventory/hosts -m service -a "name=httpd state=stopped" --become

# Remove test packages
ansible all -i inventory/hosts -m package -a "name=httpd state=absent" --become
```

## Best Practices

1. **Always test in check mode first**
2. **Use version control for changes**
3. **Maintain separate inventories for dev/staging/prod**
4. **Use Ansible Vault for sensitive data**
5. **Keep playbooks idempotent**
6. **Document all custom variables**
7. **Tag your tasks appropriately**
8. **Test rollback procedures**

## Continuous Validation

Set up pre-commit hooks:

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
./scripts/validate-playbooks.sh
if [ $? -ne 0 ]; then
    echo "Playbook validation failed!"
    exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

## Performance Testing

Monitor playbook execution time:

```bash
# Time execution
time ansible-playbook playbooks/basic/01-system-update.yml

# Use callback plugins for timing
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks,timer
ansible-playbook playbooks/basic/01-system-update.yml
```

## Security Testing

1. **Check for hardcoded secrets:**
```bash
grep -r "password\|secret\|key" playbooks/
```

2. **Verify file permissions:**
```bash
grep -r "mode:" playbooks/
```

3. **Check privilege escalation:**
```bash
grep -r "become:" playbooks/
```

## Conclusion

This testing guide ensures that all playbooks are:
- Syntactically correct
- Linted according to best practices
- Tested in dry-run mode
- Validated in test environments
- Ready for production use

For issues or questions, refer to the main README.md or open an issue.
