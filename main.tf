# module "eks_fargate" {
#   source = "./eks"  # This tells Terraform to use the local module
#
#   cluster_name = "my-eks-cluster"  # Replace with your actual cluster name
#   vpc_name     = "test" # Replace with the actual VPC name
# }
#
# module "vpc" {
#   source = "./vpc"  # This tells Terraform to use the local module
#
# }

module "vpc" {
  source = "./vpc"

  name           = "eks-vpc"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  azs            = ["us-west-2a", "us-west-2b", "us-west-2c"]
  tags = {
    Environment = "dev"
  }
}

module "s3" {
  source = "./s3"

  bucket_name = "my-s3-bucket-fares"
  tags = {
    Environment = "dev"
  }
}

module "sqs" {
  source = "./sqs"

  queue_name = "my-sqs-queue"
  tags = {
    Environment = "dev"
  }
}

module "elb" {
  source = "./elb"

  lb_name        = "my-elb"
  security_groups = [module.vpc.lb_security_group_id]
  subnets        = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id
  tags = {
    Environment = "dev"
  }
}

module "eks" {
  source = "./eks"

  cluster_name = "my-eks-cluster"
  subnet_ids   = module.vpc.private_subnets
  tags = {
    Environment = "dev"
  }
}

module "ssm" {
  source = "./ssm"

  parameter_name  = "/microservice/token"
  parameter_value = "$fares123"
  tags = {
    Environment = "dev"
  }
}