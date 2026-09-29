terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" { }

# ----- network -----

resource "oci_core_vcn" "lab_vcn" {
  compartment_id = var.tenancy_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "lab-core-vcn"
}

resource "oci_core_internet_gateway" "lab_ig" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "lab-ig"
}

resource "oci_core_route_table" "lab_rt" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "lab-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.lab_ig.id
  }
}

resource "oci_core_subnet" "lab_subnet" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "lab-public-subnet"
  route_table_id = oci_core_route_table.lab_rt.id
}

resource "oci_core_network_security_group" "lab_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "lab-vm-nsg"
}

resource "oci_core_network_security_group_security_rule" "ssh_ingress" {
  network_security_group_id = oci_core_network_security_group.lab_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "http_ingress" {
  network_security_group_id = oci_core_network_security_group.lab_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "https_ingress" {
  network_security_group_id = oci_core_network_security_group.lab_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_all_egress" {
  network_security_group_id = oci_core_network_security_group.lab_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# ----- vm -----

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "display_name"
    values = ["^.*aarch64.*$"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_instance" "lab_vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  display_name        = "lab-ubuntu-instance"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1 # max 2 for always free tiers
    memory_in_gbs = 3 # max 12 for always free tiers
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_subnet.id
    assign_public_ip = true
    display_name     = "lab-primary-vnic"
    nsg_ids          = [oci_core_network_security_group.lab_nsg.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_arm.images[0].id
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# ----- variables ------

variable "tenancy_ocid" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

# ----- output ------

output "instance_public_ip" {
  value = oci_core_instance.lab_vm.public_ip
}
