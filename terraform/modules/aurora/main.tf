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

resource "aws_db_subnet_group" "sgrp" {
  name       = "private-subnetgroup"
  subnet_ids = var.subnet_ids
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
  depends_on = [
    aws_db_subnet_group.sgrp
 ]
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
  vpc_security_group_ids    = var.vpc_security_group_ids
  db_subnet_group_name      = aws_db_subnet_group.sgrp.name
}

resource "aws_rds_cluster_instance" "instances" {
  depends_on = [
    aws_db_subnet_group.sgrp
 ]
  count                     = var.replica_count
  identifier                = "${aws_rds_cluster.postgresql.cluster_identifier}-instance-${count.index}"
  cluster_identifier        = aws_rds_cluster.postgresql.id
  instance_class            = var.instance_class
  engine                    = aws_rds_cluster.postgresql.engine
  engine_version            = aws_rds_cluster.postgresql.engine_version
  apply_immediately         = true
  db_subnet_group_name      = aws_db_subnet_group.sgrp.name
}