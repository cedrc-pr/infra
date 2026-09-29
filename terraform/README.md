# Terraform Infrastructure

This project uses Terraform to provision the cloud infrastructure required to run my servers.

The configuration is currently deployed on Oracle Cloud Infrastructure (OCI), but the infrastructure is organized around standard cloud concepts such as virtual networks, subnets, routing, network security and virtual machines.

# Infrastructure

The current configuration provisions:

- a virtual cloud network
- a public subnet
- an Internet Gateway
- network routing
- network security rules
- an Ubuntu ARM virtual machine
- a public IP address
- a boot disk

For the instance:

- Shape: VM.Standard.A1.Flex
- CPU: 1 OCPU
- Memory: 3 GB
- Boot disk: 50 GB
- OS: Ubuntu 24.04 ARM64

The VM is attached to a public subnet and receives a public IP address.

The current network security configuration allows:

- SSH : 22
- HTTP : 80
- HTTPS : 443

Outbound traffic is allowed.

# Requirements

You will need Terraform, an oracle cloud account (always free tiers is enough), OCI API credentials and an SSH key pair.

Terraform authenticates to the cloud provider through the OCI CLI configuration in `~/.oci/config`.

# Configuration

```shell
cp terraform.example.tfvars terraform.tfvars
# change the vars in it to yours

terraform apply
```

SSH access is intended to be restricted further once private network access through Tailscale is configured.
