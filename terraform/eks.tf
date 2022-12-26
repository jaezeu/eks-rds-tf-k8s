# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }
# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }
# module "eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   cluster_name    = "eks-cluster"
#   subnets         = module.vpc.public_subnets
#   vpc_id          = module.vpc.vpc_id
#   kubeconfig_output_path = "~/.kube/"
#   node_groups = {
#     first = {
#       desired_capacity = 2
#       max_capacity =  3
#       min_capacity = 1
#       instance_type = "t3.small"
#     }
#   }
# }
# resource "null_resource" "java"{
#   depends_on = [module.eks]
#   provisioner "local-exec" {
#     command = "aws eks --region eu-central-1  update-kubeconfig --name $AWS_CLUSTER_NAME"
#     environment = {
#       AWS_CLUSTER_NAME = "eks-cluster"
#     }
#   }
# }