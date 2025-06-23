project_name = "eks-vpc"
region = "us-east-1"

vpc_configuration = {
  cidr_block = "10.0.0.0/16"
  subnets = [
    {
      name              = "general-private-1a"
      public            = false
      availability_zone = "us-east-1a"
      cidr_block        = "10.0.0.0/20"
    },
    {
      name       = "general-private-1b"
      public     = false
      availability_zone = "us-east-1b"
      cidr_block = "10.0.16.0/20"
    },
    {
      name       = "general-private-1c"
      public     = false
      availability_zone = "us-east-1c"
      cidr_block = "10.0.32.0/20"
    },
    {
      name       = "general-public-1a"
      public     = true
      availability_zone = "us-east-1a"
      cidr_block = "10.0.48.0/24"
    },
    {
      name       = "general-public-1b"
      public     = true
      availability_zone = "us-east-1b"
      cidr_block = "10.0.49.0/24"
    },
    {
      name       = "general-public-1c"
      public     = true
      availability_zone = "us-east-1c"
      cidr_block = "10.0.50.0/24"
    },
    {
      name       = "pods-1a"
      public     = false
      availability_zone = "us-east-1a"
      cidr_block = "100.64.0.0/18"
    },
    {
      name       = "pods-1b"
      public     = false
      availability_zone = "us-east-1b"
      cidr_block = "100.64.64.0/18"
    },
    {
      name       = "pods-1c"
      public     = false
      availability_zone = "us-east-1c"
      cidr_block = "100.64.128.0/18"
    },
    {
      name       = "db-1a"
      public     = false
      availability_zone = "us-east-1a"
      cidr_block = "10.0.51.0/24"
    },
    {
      name       = "db-1b"
      public     = false
      availability_zone = "us-east-1b"
      cidr_block = "10.0.52.0/24"
    },
    {
      name       = "db-1c"
      public     = false
      availability_zone = "us-east-1c"
      cidr_block = "10.0.53.0/24"
    }
  ]
}

vpc_additional_cidrs = [
  "100.64.0.0/16"
]