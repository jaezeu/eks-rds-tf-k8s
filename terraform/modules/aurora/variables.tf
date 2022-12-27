variable "cluster_identifier" {
    description = "Name of the RDS Cluster"
}

variable "engine" {
    description = "Database Engine"
}

variable "engine_version" {
    description = "Database engine version"
}

variable "database_name" {
    description = "Name of the database"
}

variable "master_username" {
    description = "Master username to access the DB"
}

variable "backup_retention_period" {
    description = "DB backup retention period"
}

variable "preferred_backup_window" {
    description = "Backup window"
}

variable "replica_count" {
    description = "DB replica count"
}

variable "instance_class" {
    description = "DB instance class"
}

variable "subnet_ids" {
    description = "subnet ids to create subnet group for the RDS cluster"
}

variable "vpc_security_group_ids" {
    description = "Security groups to be attached to the RDS"
}

variable "subnet_group_name" {
    description = "Name of the subnet group"
}

variable "cluster_pg_name" {
    description = "Name of the cluster parameter group"
}

variable "pg_family" {
    description = "Name of the cluster parameter group family"
}

variable "parameters" {
  type        = list(map(string))
  default     = []
}