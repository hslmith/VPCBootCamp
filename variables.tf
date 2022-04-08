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