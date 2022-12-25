output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.postgresql.cluster_endpoint
}