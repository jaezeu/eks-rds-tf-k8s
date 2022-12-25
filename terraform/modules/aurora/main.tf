provider "aws" {
#   region  = var.aws_region 
}

resource "random_password" "master"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "random_id" "rng" {
  keepers = {
    first = "${timestamp()}"
  }     
  byte_length = 8
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "master-credentials-${random_id.rng.hex}"

    rotation_rules {
        automatically_after_days = 7
  }
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${aws_rds_cluster.postgresql.master_username}",
  "password": "${random_password.master.result}",
  "engine": "${var.engine}",
  "host": "${aws_rds_cluster.postgresql.endpoint}",
  "port": ${aws_rds_cluster.postgresql.port},
  "dbClusterIdentifier": "${aws_rds_cluster.postgresql.cluster_identifier}"
}
EOF
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier        = var.cluster_identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  database_name             = var.database_name
  master_username           = var.master_username
  master_password           = random_password.master.result
  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window
  storage_encrypted         = true
  final_snapshot_identifier = "${var.cluster_identifier}-final-${random_id.rng.hex}"
  vpc_security_group_ids    = [aws_security_group.this.id]
}

resource "aws_rds_cluster_instance" "instances" {
  count                     = var.replica_count
  identifier                = "${aws_rds_cluster.postgresql.cluster_identifier}-instance-${count.index}"
  cluster_identifier        = aws_rds_cluster.postgresql.id
  instance_class            = var.instance_class
  engine                    = aws_rds_cluster.postgresql.engine
  engine_version            = aws_rds_cluster.postgresql.engine_version
  apply_immediately         = true
}

resource "aws_security_group" "this" {
  name   = var.sg_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_group["ingress"]
    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      security_groups  = lookup(ingress.value, "security_group", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      self             = lookup(ingress.value, "self", false)
    }
  }

  dynamic "egress" {
    for_each = var.security_group["egress"]
    content {
      description      = lookup(egress.value, "description", null)
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      security_groups  = lookup(egress.value, "security_group", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      self             = lookup(egress.value, "self", false)
    }
  }
}