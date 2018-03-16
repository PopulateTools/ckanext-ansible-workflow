#!/bin/bash

ansible-playbook --ask-vault-pass ckan_production.yml -i inventory -vv -u root --extra-vars "deploy_action=rollback ckan_env=production"