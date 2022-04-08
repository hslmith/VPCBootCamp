////////////////
//Define Zones
////////////////


variable "ibmcloud_region" {
  description = "Preferred IBM Cloud region to use for your infrastructure"
  default = "us-south"
}

variable "zone1" {
  default = "us-south-1"
  description = "Define the 1st zone of the region"
}

variable "zone2" {
  default = "us-south-2"
  description = "Define the 2nd zone of the region"
}


////////////////
//Define VPC
////////////////

variable "vpc_name" {
  default = "vpc-bootcamp"
  description = "Name of your VPC"
}


variable "cis_resource_group" {
  default = "default"
}


////////////////
// Define CIDR
////////////////


variable "zone1_prefix" {
  default = "10.10.0.0/18"
  description = "CIDR block to be used for zone 1"
}

variable "zone2_prefix" {
  default = "10.20.0.0/18"
  description = "CIDR block to be used for zone 2"
}

////////////////////////////////
// Define Subnets for zones
////////////////////////////////

variable "web_subnet_zone1" {
  default = "10.10.10.0/24"
}

variable "db_subnet_zone1" {
  default = "10.10.20.0/24"
}



variable "web_subnet_zone2" {
  default = "10.20.30.0/24"
}

variable "db_subnet_zone2" {
  default = "10.20.40.0/24"
}

////////////////////////////////




variable "ssh_key_name" {
  default = "vpc-rsa"
  description = "Name of existing VPC SSH Key"
}

variable "web_server_count" {
  default = 1
}

variable "db_server_count" {
  default = 1
}

variable "image" {
  default = "r006-b9ebf1d8-a674-42e8-898e-0fcb08994f66"
  description = "OS Image ID to be used for virtual instances"
}

variable "profile" {
  default = "bx2-2x8"
  description = "Instance profile to be used for virtual instances"
}


// LBaaS Define


variable "webtier-lb-connections" {
  default = 2000
}

variable "webtier-lb-algorithm" {
  default = "round_robin"
}