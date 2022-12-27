module "postgresql" {
  source = "./modules/aurora"
  providers = {
    aws = aws.ap-southeast-1
  }
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "13.7"
  database_name           = "mydb"
  master_username         = "foobar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  instance_class          = "db.r5.large"
  replica_count           = 1
  subnet_ids              = module.vpc.private_subnets
  vpc_security_group_ids  = [module.postgresql-sg.sg_id]
  subnet_group_name       = "postgres-private-subnets"
  cluster_pg_name         = "rds-cluster-pg"
  pg_family               = "aurora-postgresql13"

  #Adding example usage of parameters
  parameters              = [
    {
      name  = "character_set_connection"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "log_bin_trust_function_creators"
      value = "1"
    }
  ]
}


# Security group to attach to the aurora rds being created above
# For this testing use case, im opening it up to the subnets where the EKS would be residing in
# I would not recommend this for a production usecase, as other workloads may also reside in those subnets, including node groups that do not require access to the RDS
# It would be better to open the inbound connections to the node groups security group in port 5432.
# Outbound opened to all since RDS is a managed service by AWS


module "postgresql-sg" {
  source            = "./modules/security_group"
  providers         = {
    aws             = aws.ap-southeast-1
  }
  sg_name           = "postgres-sg"
  vpc_id            = module.vpc.vpc_id
  security_group    = {
    name            = "postgres-sg",
    ingress         = [
      {
        type        = "ingress"
        cidr_blocks = [module.vpc.public_subnets_cidr_blocks[0], module.vpc.public_subnets_cidr_blocks[1]]
        description = "Allows traffic on Port 5432"
        from_port   = "5432"
        to_port     = "5432"
        protocol    = "tcp"
      },
    ],
    egress          = [
      {
        type        = "egress"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow All Outbound"
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
      }
    ]
  }
}
