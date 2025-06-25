#!/bin/bash

# Convenience script to run the Ansible playbook

echo "=== Development Environment Setup ==="
echo

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: Ansible is not installed. Please install Ansible first."
    echo "Visit: https://docs.ansible.com/ansible/latest/installation_guide/index.html"
    exit 1
fi

# Run the playbook
echo "Running Ansible playbook..."
ansible-playbook development-environment-setup.yml "$@"
