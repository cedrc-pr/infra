# Overview

This project is an Ansible playbook that can fully configure servers and deploy everything required for my [Copit](https://github.com/cedrc-pr/copit) application (but can accept multiple apps).
It works on debian 13 trixie and on fedora 44 servers.

I have made this project to continue discovering DevOps just after the [python projects](https://github.com/cedrc-pr/python-projects).

It contains various roles:

- security
  - ssh hardening
  - automatic security updates
  - ufw or firewalld
  - CrowdSec or fail2ban
- environment
  - docker
  - ghcr login
  - services folder
- traefik
  - as reverse-proxy
  - http & https
  - letsencrypt
  - secure headers
- [copit](https://github.com/cedrc-pr/copit)
  - my app
  - script for safe deployment
- [deployer](https://github.com/cedrc-pr/deployer)
  - as a daemon
  - binding in a docker subnet
  - dynamic configuration

# Workflow

- push on main in copit repository:
  - build images
  - push images on ghrc.io
  - call the deployer with:
    - service name to safely redeploy
    - with token from github secrets
- request received by traefik
  - in https
  - redirect to the deployer systemd
  - deployer receive the request
    - validate service and token
    - start the associated script

# Deployment

```shell
cp inventory.example.ini inventory.ini
cp host_vars.example/ host_vars/
cp group_vars/all/vault.example.yml group_vars/all/vault.yml

ansible-vault encrypt group_vars/all/vault.yml host_vars/SERVER-A/vault.yml host_vars/SERVER-B/vault.yml
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

On fedora servers, no need to do much, the account used to connect with ansible must be able to connect with the public key.

For debian, if you have chose a minimal configuration (only SSH server and standard system utilities), you will need to:

```shell
su -
apt udpate && apt install -y sudo curl
usermod -aG sudo USERNAME
```

# If you made it this far

There’s a tool that’s made writing and navigating through all these folders and files so much easier for me; it’s called [Yazi](https://yazi-rs.github.io/). I’m just mentioning it here, but this sort of project really made me fall in love with this file manager.
