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
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-cluster"
  cluster_version = "1.23"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
}
resource "null_resource" "java"{
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks --region ap-southeast-1 update-kubeconfig --name ${module.eks.cluster_name}"
  }
}