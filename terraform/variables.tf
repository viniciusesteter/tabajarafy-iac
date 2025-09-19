## Variables for AWS provider
variable "aws_region" {
	type    = string
	default = "us-east-1"
}

## Variables for EKS Cluster
variable "cluster_name" {
	type    = string
	default = "tabajarafy-eks"
}

variable "tags_eks_cluster" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-eks"
  }
}

variable "tags_eks_iam" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-eks-iam"
  }
}

## Variables for VPC
variable "vpc_cidr" {
	type    = string
	default = "10.0.0.0/16"
}

variable "aws_vpc_tags_name" {
	type    = map(string)
  	default = {
		Environment = "prd"
		Project     = "tabajarafy-vpc"
  }
}

variable "aws_igw_tags_name" {
	type    = map(string)
  	default = {
		Environment = "prd"
		Project     = "tabajarafy-igw"
  }
}

variable "route_table_public" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-public-rt"
  }
}

variable "route_table_private" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-private-rt"
  }
}

variable "eip" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-eip"
  }
}

variable "natgw" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-natgw"
  }
}

variable "public_subnet_cidrs" {
	type    = list(string)
	default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "aws_public_subnet_tags_name" {
	type    = string
	default = "tabajarafy-public-"
}

variable "aws_private_subnet_tags_name" {
	type    = string
	default = "tabajarafy-private-"
}

variable "route_table_public_cidr" {
	type    = string
	default = "0.0.0.0/0"
}

variable "route_private_destination" {
	type    = string
	default = "0.0.0.0/0"
}

variable "nat_domain" {
	type    = string
	default = "vpc"
}

variable "private_subnet_cidrs" {
	type    = list(string)
	default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

## Variables for Node Group
variable "node_group_name" {
	type    = string
	default = "tabajarafy-ng" 
}

variable "tags_ng" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-ng"
  }
}

variable "nodes_sg" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-nodes-sg"
  }
  
}

variable "node_instance_type" {
	type    = string
	default = "t3.small"
}

variable "desired_size" {
	type    = number
	default = 10
}

variable "max_size" {
	type    = number
	default = 20
}

variable "min_size" {
	type    = number
	default = 4 
}

variable "node_sg_name" {
	type    = string
	default = "tabajarafy-node-sg"
}

variable "ingress_from_port_node_sg" {
	type    = number
	default = 443
}

variable "ingress_to_port_node_sg" {
	type    = number
	default = 443
}

variable "ingress_protocol_node_sg" {
	type    = string
	default = "tcp"
}

variable "ingress_from_port_node_sg_1" {
	type    = number
	default = 1025
}

variable "ingress_to_port_node_sg_1" {
	type    = number
	default = 65535
}

variable "ingress_protocol_node_sg_1" {
	type    = string
	default = "tcp"
}

variable "egress_from_port_node_sg" {
	type    = number
	default = 0
}

variable "egress_to_port_node_sg" {
	type    = number
	default = 0
}

variable "egress_protocol_node_sg" {
	type    = string
	default = "-1"
}

variable "egress_cidr_blocks_node_sg" {
	type    = list(string)
	default = ["0.0.0.0/0"]
}

variable "tags_nodes_iam" {
  type    = map(string)
  default = {
	Environment = "prd"
	Project     = "tabajarafy-nodes-iam"
  }
  
}

## Variables for IAM Role
variable "eks_cluster_role_name" {
	type    = string
	default = "tabajarafy-eks-cluster-role"
}

variable "eks_cluster_pass_role" {
	type    = string
	default = "tabajarafy-eks-pass-role"
}

variable "eks_node_role_name" {
	type    = string
	default = "tabajarafy-eks-node-role"
}

variable "eks_node_pass_role" {
	type    = string
	default = "tabajarafy-eks-node-passrole"
}

variable "iam_group_name" {
  type    = string
  default = "tabajarafy-iam-group"
}
