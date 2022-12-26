module "postgresql" {
  source                  = "./modules/aurora"
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
  replica_count           = 2
  sg_name                 = "postgres-sg"
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  security_group = {
    name = "postgres-sg",
    ingress = [
      {
        type        = "ingress"
        cidr_blocks = [module.vpc.public_subnets[0],module.vpc.public_subnets[1]]
        description = "Allows traffic on Port 5432"
        from_port   = "5432"
        to_port     = "5432"
        protocol    = "tcp"
      },
    ],
    egress = [
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
