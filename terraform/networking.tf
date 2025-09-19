resource "aws_vpc" "main" {
	cidr_block = var.vpc_cidr
	tags = var.aws_vpc_tags_name
}

resource "aws_internet_gateway" "gw" {
	vpc_id = aws_vpc.main.id
	tags = var.aws_igw_tags_name
}

resource "aws_subnet" "public" {
	count = length(var.public_subnet_cidrs)
	vpc_id = aws_vpc.main.id
	cidr_block = var.public_subnet_cidrs[count.index]
	map_public_ip_on_launch = true
	availability_zone = data.aws_availability_zones.available.names[count.index]
	tags = { Name = "${var.aws_public_subnet_tags_name}${count.index}" }
  	depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private" {
	count = length(var.private_subnet_cidrs)
	vpc_id = aws_vpc.main.id
	cidr_block = var.private_subnet_cidrs[count.index]
	map_public_ip_on_launch = false
	availability_zone = data.aws_availability_zones.available.names[count.index]
	tags = { Name = "${var.aws_private_subnet_tags_name}${count.index}" }
  	depends_on = [aws_nat_gateway.natgw, aws_subnet.public]
}

resource "aws_route_table" "public" {
	vpc_id = aws_vpc.main.id
	tags = var.route_table_public
	route {
		cidr_block = var.route_table_public_cidr
		gateway_id = aws_internet_gateway.gw.id
	}
}

resource "aws_route_table_association" "public_assoc" {
	count = length(aws_subnet.public)
	subnet_id = aws_subnet.public[count.index].id
	route_table_id = aws_route_table.public.id
  	depends_on = [aws_route_table.public, aws_subnet.public, aws_internet_gateway.gw]
}

# NAT Gateway (single) + Elastic IP
resource "aws_eip" "nat" {
  domain = var.nat_domain
  tags = var.eip
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "natgw" {
	allocation_id = aws_eip.nat.id
	subnet_id = aws_subnet.public[0].id
	tags = var.natgw
	depends_on = [aws_eip.nat, aws_internet_gateway.gw, aws_subnet.public]
}


resource "aws_route_table" "private" {
	vpc_id = aws_vpc.main.id
	tags = var.route_table_private
}

resource "aws_route" "private_nat_gateway" {
	route_table_id         = aws_route_table.private.id
	destination_cidr_block = var.route_private_destination
	nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private_assoc" {
	count = length(aws_subnet.private)
	subnet_id = aws_subnet.private[count.index].id
	route_table_id = aws_route_table.private.id
  	depends_on = [aws_route_table.private, aws_subnet.private]
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "node_sg" {
	name   = var.node_sg_name
	vpc_id = aws_vpc.main.id
	tags = var.nodes_sg
	ingress {
		from_port   = var.ingress_from_port_node_sg
		to_port     = var.ingress_to_port_node_sg
		protocol    = var.ingress_protocol_node_sg
		cidr_blocks = [var.vpc_cidr]
	}
	ingress {
		from_port   = var.ingress_from_port_node_sg_1
		to_port     = var.ingress_to_port_node_sg_1
		protocol    = var.ingress_protocol_node_sg_1
		cidr_blocks = [var.vpc_cidr]
	}
	egress {
		from_port   = var.egress_from_port_node_sg
		to_port     = var.egress_to_port_node_sg
		protocol    = var.egress_protocol_node_sg
		cidr_blocks = var.egress_cidr_blocks_node_sg
	}

}
