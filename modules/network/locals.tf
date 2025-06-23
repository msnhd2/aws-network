# SORT - Used to ensure that the subnet names are in order
# SLICE - Used to ensure that we get the same amount of availability zones for the number of private subnets
# ZIPMAP - Takes two lists of the same size, and makes a map of the first item in the public list with the first item in the private list
# MERGE - Used to merge two maps into one

locals {
    all_private_subnets = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if subnet.public == false ])
    private_subnets = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if strcontains(subnet.name, "private") && subnet.public == false  ])
    public_subnets = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if subnet.public == true ])
    subnet_pairs = { for idx, private in local.all_private_subnets : private => element(local.public_subnets, idx % length(local.public_subnets)) }
    # Create routes for all private subnets and point each to the correct NAT Gateway (using the public/private subnet pair per AZ)
    subnet_az_map = { for subnet in var.vpc_configuration.subnets : subnet.name => subnet.availability_zone }
    az_to_nat_subnet = { for subnet in var.vpc_configuration.subnets : subnet.availability_zone => subnet.name if subnet.public == false && strcontains(subnet.name, "private") }
    
    #db_subnets = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if strcontains(subnet.name, "db") && subnet.public == false ])
    #pod_subnets = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if strcontains(subnet.name, "pod") && subnet.public == false ])
    #avzo = sort(slice(data.aws_availability_zones.available.zone_ids, 0 ,length(local.private_subnets)))
    #subnet_pairs = zipmap(local.private_subnets, local.public_subnets)
    # az_pairs = merge(
    #     zipmap(local.private_subnets, local.avzo),
    #     zipmap(local.public_subnets, local.avzo)
    # )
}