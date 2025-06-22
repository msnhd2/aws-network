resource "aws_vpc" "this" {
  cidr_block = var.vpc_configuration.cidr_block

  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = format("${var.project_name}-vpc")
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
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("${var.project_name}-igw")
    Environment = "dev"
  }
}

resource "aws_subnet" "this" {
  for_each = { for subnet in var.vpc_configuration.subnets : subnet.name => subnet }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
# Colocar o id da availability zone hard coded não é uma boa prática pois pode ser alterado com o passar do tempo.
# Criei um data para buscar as availability zones disponiveis na região que utilizamos na aws.
  availability_zone = local.az_pairs[each.key] #each.key buscar o subnet.name

  map_public_ip_on_launch = each.value.public

  tags = {
    Name        = format("${var.project_name}-${each.value.name}-subnet")
    Environment = "dev"
  }
  
}

