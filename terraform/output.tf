#Obtain database url
output "postgres_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.postgresql.cluster_endpoint
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}