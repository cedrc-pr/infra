# Infrastructure

This project contains the infrastructure required to provision, configure and deploy my servers and applications.

It combines:

- Terraform for Infrastructure as Code and cloud resource provisioning
- Ansible for server configuration and application deployment

The current cloud infrastructure is hosted on Oracle Cloud Infrastructure (OCI).

This project is part of my ongoing exploration of DevOps, Infrastructure as Code, cloud infrastructure and deployment automation.

# Terraform

Terraform provisions the cloud resources required to run the servers.

See `terraform/README.md` for setup and usage.

# Ansible

Ansible configures the provisioned servers and deploys the required services and applications.

See `ansible/README.md` for setup and usage.

# Related projects

- [Copit](https://github.com/cedrc-pr/copit)
- [Deployer](https://github.com/cedrc-pr/deployer)

Those projects github workflows needed to be adapted since they needed to work on ARM instances.
