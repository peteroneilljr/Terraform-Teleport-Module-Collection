# Teleport Modules 

Examples in this repository are for educational purposes only. These modules are designed with simplicity in mind and create self contained demos for testing purposes. 

Any code taken from this repository should undergo security scrutiny if it is to used in an environment with sensitve data. 

## terraform-teleport-agent

Deploys an Agent to connect additional resources into your Teleport Cluster.

```hcl
module "sudo" {
  source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"

  create = local.teleport.sudo

  cloud = "AWS"

  aws_vpc_id            = module.vpc.vpc_id
  aws_security_group_id = module.vpc.default_security_group_id
  aws_subnet_id         = module.vpc.private_subnets[2]

  agent_nodename = "sudo-test"

  teleport_ssh_labels    = { "app" = "sudo" }
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_agent_roles   = []

  aws_key_pair = aws_key_pair.peter.id

}
```

## terraform-teleport-aws

Adds an AWS app to your Teleport Cluster

```hcl
module "terraform-teleport-aws" {
  source                 = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-app-aws"
  prefix                 = local.prefix
  aws_vpc_id             = module.vpc.vpc_id
  aws_security_group_id  = module.vpc.default_security_group_id
  aws_subnet_id          = module.vpc.private_subnets[0]
  aws_key_pair           = aws_key_pair.peter.id
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
}
```

## terraform-teleport-app-gcp-cli

Adds GCP CLI as a resource into your cluster.

```hcl
module "terraform-teleport-gcp-cli" {
  source                 = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-app-gcp-cli"
  prefix                 = local.prefix
  gcp_project            = var.gcp_project
  gcp_region             = var.gcp_region
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
}
```

## terraform-teleprot-cluster-aws

Deploys a self hosted Teleport cluster on EKS, as well as a DynamoDB backend and S3 bucket for recording storage.

## terraform-teleport-demo

All in one module to deploy a self hosted cluster and underlying VPC and EKS cluster.

## terraform-teleport-standalone

Deploys Teleport cluster in standalone mode. All resources are maintained within the EKS cluster.

## terraform-teleport-resource-auto-discovery

Deploys EC2 auto-discovery demo. 

```hcl
module "terraform-teleport-auto-discovery" {
  source                 = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-resource-auto-discovery"
  count                  = local.teleport.auto_discovery ? 1 : 0
  prefix                 = local.prefix
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  aws_key_name           = aws_key_pair.peter.id
  aws_account            = var.aws_account_id
  aws_vpc_id             = module.vpc.vpc_id
  aws_security_group_id  = module.vpc.default_security_group_id
  aws_subnet_id          = module.vpc.private_subnets[0]
  aws_ami                = local.ami.amzn_linux
}
```

## terraform-teleport-resource-rds-postgres

Deploys an RDS instance and the necessary resources to connect it to Teleport.

```hcl
module "terraform-teleport-rds" {
  source                = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-resource-rds-postgres"
  count                 = local.teleport.rds ? 1 : 0
  prefix                = local.prefix
  aws_vpc_id            = module.vpc.vpc_id
  aws_security_group_id = module.vpc.default_security_group_id
  aws_key_name          = aws_key_pair.peter.id
  aws_subnet_ids        = module.vpc.private_subnets

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
}
```

## terraform-teleport-resource-windows

Deploys a windows instance and connects it to a Teleport cluster.

```hcl
module "terraform-teleport-windows" {
  source                 = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-resource-windows"
  count                  = local.teleport.rdp ? 1 : 0
  aws_ami_windows        = local.ami.windows
  aws_key_name           = aws_key_pair.peter.id
  aws_subnet_id          = module.vpc.private_subnets[3]
  aws_vpc_id             = module.vpc.vpc_id
  aws_security_group_id  = module.vpc.default_security_group_id
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
}
```

