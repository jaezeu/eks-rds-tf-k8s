data "aws_vpc" "default" {
  default = true
} 

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
  vpc_id                  = data.aws_vpc.default.id
  security_group = {
    name = "postgres-sg",
    ingress = [
      {
        type        = "ingress"
        cidr_blocks = ["0.0.0.0/32", "192.168.23.8/32"]
        description = "Allows traffic on Port 80"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
      },
      {
        type        = "ingress"
        cidr_blocks = ["0.0.0.0/32", "192.168.23.8/32"]
        description = "Allows traffic on Port 8000"
        from_port   = "8000"
        to_port     = "8000"
        protocol    = "tcp"
      },
      {
        cidr_blocks = ["0.0.0.0/32", "192.168.23.8/32"]
        type        = "ingress"
        description = "Allows traffic on Port 443"
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
      }
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