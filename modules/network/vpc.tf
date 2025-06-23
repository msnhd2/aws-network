resource "aws_vpc" "this" {
  cidr_block = var.vpc_configuration.cidr_block

  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = strcontains(var.project_name, "-vpc") ? var.project_name : format("${var.project_name}-vpc")
    Environment = "dev"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "additional_cidrs" {
  for_each = try(toset(var.vpc_additional_cidrs), [])
  # Ensure that the additional CIDRs are valid and not empty
  # If no additional CIDRs are provided, use an empty set to avoid errors
  # This will prevent the resource from being created if the list is empty
  
  vpc_id   = aws_vpc.this.id
  cidr_block = each.value

  depends_on = [ aws_vpc.this ]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("${var.project_name}-igw")
    Environment = "dev"
  }

  depends_on = [ aws_vpc.this ]
}

resource "aws_subnet" "this" {
  for_each = { for subnet in var.vpc_configuration.subnets : subnet.name => subnet }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone  = each.value.availability_zone

  #map_public_ip_on_launch = each.value.public

  tags = {
    Name        = format("${var.project_name}-${each.value.name}-subnet")
    Environment = "dev"
  }
  
  depends_on = [ aws_vpc.this, aws_vpc_ipv4_cidr_block_association.additional_cidrs ]
  
}


resource "aws_eip" "nat_gateway" {
  for_each = toset(local.private_subnets)
  domain = "vpc"

  depends_on = [
    aws_internet_gateway.this,
    aws_subnet.this
    ]
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.private_subnets)

  allocation_id = aws_eip.nat_gateway[each.value].id
# Ensure that the Nat gateway is in the correct availability zone and public subnet for the respective private subnet used
  subnet_id = aws_subnet.this[local.subnet_pairs[each.value]].id

  depends_on = [ aws_eip.nat_gateway ]
}


# Rotas públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-public-route-table"
  }

  depends_on = [ 
    aws_vpc.this,
    aws_subnet.this
  ]
}

resource "aws_route" "internet_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.this.id

  depends_on = [
    aws_route_table.public
  ]
}

resource "aws_route_table_association" "public" {
# The toset function was used to remove duplicate items from the list passed as a parameter, and discard the ordering.
# Documentation toset(https://www.terraform.io/language/functions/toset)
  for_each = toset(local.public_subnets) 
  subnet_id = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.public.id

  depends_on = [ aws_route_table.public ]
}


# Rotas privadas
resource "aws_route_table" "private" {
  # Exclude DB subnets from the private route table association
  for_each = { for subnet in local.all_private_subnets : subnet => subnet if !strcontains(subnet, "db") }
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-%s", "${var.project_name}", each.value)
  }

  depends_on = [ 
    aws_vpc.this,
    aws_subnet.this
  ]
}

resource "aws_route" "private" {
  # Exclude DB subnets from the private route table association
  for_each = { for subnet in local.all_private_subnets : subnet => subnet if !strcontains(subnet, "db") }
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.private[each.value].id
  
  # Ensure that the NAT Gateway is used for the correct private subnet based on the availability zone
  nat_gateway_id = aws_nat_gateway.this[local.az_to_nat_subnet[local.subnet_az_map[each.value]]].id

  depends_on = [
    aws_route_table.private  
  ] 
}

resource "aws_route_table_association" "private" {
  # Exclude DB subnets from the private route table association
  for_each = { for subnet in local.all_private_subnets : subnet => subnet if !strcontains(subnet, "db") }
  
  subnet_id = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.private[each.value].id

  depends_on = [ 
    aws_route_table.private
  ]
}
