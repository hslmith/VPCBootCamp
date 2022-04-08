##############################################################################
# SSH Key 
##############################################################################

data "ibm_is_ssh_key" "sshkey1" {
  name = "${var.ssh_key_name}"
}


##############################################################################
# Create VPC
##############################################################################

resource "ibm_is_vpc" "vpc1" {
  name = "${var.vpc_name}"
  address_prefix_management = "manual"
}

//--- security group creation for web tier


resource "ibm_is_security_group" "public_facing_sg" {
    name = "${var.vpc_name}-public-facing-sg1"
    vpc  = "${ibm_is_vpc.vpc1.id}"
}

resource "ibm_is_security_group_rule" "public_facing_tcp22" {
    group = "${ibm_is_security_group.public_facing_sg.id}"
    direction = "inbound"
    remote = "0.0.0.0/0"
    tcp {
      port_min = "22"
      port_max = "22"
    }
}

resource "ibm_is_security_group_rule" "public_facing_sg_tcp80" {
    group = "${ibm_is_security_group.public_facing_sg.id}"
    direction = "inbound"
    remote = "0.0.0.0/0"
    tcp {
      port_min = "80"
      port_max = "80"
    }
}

resource "ibm_is_security_group_rule" "public_facing_icmp" {
    group = "${ibm_is_security_group.public_facing_sg.id}"
    direction = "inbound"
    remote = "0.0.0.0/0"
    icmp {
      code = "0"
      type = "8"
    }
}

resource "ibm_is_security_group_rule" "public_facing_egress" {
    group = "${ibm_is_security_group.public_facing_sg.id}"
    direction = "outbound"
    remote = "0.0.0.0/0"
}


//--- security group creation for db tier

resource "ibm_is_security_group" "private_facing_sg" {
    name = "${var.vpc_name}-private-facing-sg"
    vpc = "${ibm_is_vpc.vpc1.id}"
}



///////////////////////////////////////
// Public Gateway's for Zone 1
////////////////////////////////////////


resource "ibm_is_public_gateway" "pubgw-zone1" {
  name = "${var.vpc_name}-${var.zone1}-pubgw"
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone1}"
}