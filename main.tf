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


##############################################################################
# Prefixes for Zone 1 & Zone 2
##############################################################################


resource "ibm_is_vpc_address_prefix" "prefix_z1" {
  name = "vpc-zone1-cidr"
  zone = var.zone1
  vpc  = ibm_is_vpc.vpc1.id
  cidr = var.zone1_prefix
  is_default  = true
}

resource "ibm_is_vpc_address_prefix" "prefix_z2" {
  name = "vpc-zone2-cidr"
  zone = var.zone2
  vpc  = ibm_is_vpc.vpc1.id
  cidr = var.zone2_prefix
  is_default  = true
}

##############################################################################
# Subnets for Zone 1 & Zone 2
##############################################################################

#--- subnets for web and db tier zone 1

resource "ibm_is_subnet" "websubnet1" {
  name            = "web-subnet-zone1"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone1
  ipv4_cidr_block = var.web_subnet_zone1
  depends_on      = [ibm_is_vpc_address_prefix.prefix_z1]
}


resource "ibm_is_subnet" "dbsubnet1" {
  name            = "db-subnet-zone1"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone1
  ipv4_cidr_block = var.db_subnet_zone1
  depends_on      = [ibm_is_vpc_address_prefix.prefix_z1]
}

#--- subnets for web and db tier zone 2

resource "ibm_is_subnet" "websubnet2" {
  name            = "web-subnet-zone2"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone2
  ipv4_cidr_block = var.web_subnet_zone2
  depends_on      = [ibm_is_vpc_address_prefix.prefix_z2]
}


resource "ibm_is_subnet" "dbsubnet2" {
  name            = "db-subnet-zone2"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone2
  ipv4_cidr_block = "${var.db_subnet_zone2}"
  depends_on      = [ibm_is_vpc_address_prefix.prefix_z2]
}



##############################################################################
# ZONE 1 (L)
##############################################################################


#--- Web Server(s)

resource "ibm_is_instance" "web-instancez01" {
  count   = var.web_server_count
  name    = "webz01-${count.index+1}"
  image   = var.image
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.websubnet1.id
    security_groups = ["${ibm_is_security_group.public_facing_sg.id}"]
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone1
  keys = ["${data.ibm_is_ssh_key.sshkey1.id}"]
  #user_data = "${data.local_file.cloud-config-web-txt.content}
}


#--- DB Server(s) 


resource "ibm_is_instance" "db-instancez01" {
  count   = var.db_server_count
  name    = "dbz01-${count.index+1}"
  image   = var.image
  profile = var.profile

  primary_network_interface  {
    subnet = ibm_is_subnet.dbsubnet1.id
    security_groups = ["${ibm_is_security_group.private_facing_sg.id}"]
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone1
  keys = ["${data.ibm_is_ssh_key.sshkey1.id}"]
  #user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
}



##############################################################################
# ZONE 2 (R)
##############################################################################

#--- Web Server(s)

resource "ibm_is_instance" "web-instancez02" {
  count   = var.web_server_count
  name    = "webz02-${count.index+1}"
  image   = var.image
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.websubnet2.id
    security_groups = ["${ibm_is_security_group.public_facing_sg.id}"]
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone2
  keys = ["${data.ibm_is_ssh_key.sshkey1.id}"]
  user_data = "${file("install_apache.sh")}"
  #user_data = "${data.local_file.cloud-config-web-txt.content}
}


#--- DB Server(s) 


resource "ibm_is_instance" "db-instancez02" {
  count   = var.db_server_count
  name    = "dbz02-${count.index+1}"
  image   = var.image
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.dbsubnet2.id
    security_groups = ["${ibm_is_security_group.private_facing_sg.id}"]
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone2
  keys = ["${data.ibm_is_ssh_key.sshkey1.id}"]
  #user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
}