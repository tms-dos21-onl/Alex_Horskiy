#!/bin/bash
echo "Deploying Docker containers using Ansible..."
ansible-playbook -i ansible/inventories/production/hosts ansible/playbooks/deploy.yml
