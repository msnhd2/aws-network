module "network" {
  source = "./modules/network"
  
  project_name = var.project_name
  vpc_configuration = var.vpc_configuration
  vpc_additional_cidrs = var.vpc_additional_cidrs
}