## GitHub File/Folder Structure

| File / Folder Name | Location | Usage |
| --- | --- | --- |
| README.md | `root` | Contains the details of contents present in the repo, including usage and architectural decisions |
| configmap.yaml | `root/kubernetes/` | This file is used to create the configmap with the json file to be mounted to the deployment |
| deployment.yaml | `root/kubernetes/` | This file is used to deploy the nodejs application |
| hpa.yaml | `root/kubernetes/` | This file is used to create the horizontal pod autoscaler to scale the deployment |
| ingress.yaml | `root/kubernetes/` | This file is used to create the ingress resource using AWS ALB |
| service.yaml | `root/kubernetes/` | This file is used to expose the deployment as a NodePort service |
| main.tf | `root/terraform/module/aurora` & `root/terraform/module/security_group` | Declaration of resources for the aurora and security_group modules |
| output.tf | `root/terraform/module/aurora` & `root/terraform/module/security_group` | Output values for the terraform modules |
| variables.tf | `root/terraform/module/aurora` & `root/terraform/module/security_group` | Input variables for terraform modules |
| backend.tf | `root/terraform/` | Backend to store terraform state in s3 and statelock using dynamodb(Created outside of this terraform) |
| eks.tf | `root/terraform/` | Creation of EKS resource using community module and output kubeconfig file location |
| output.tf | `root/terraform/` | Output values passed from modules |
| postgres.tf | `root/terraform/` | Creation of Aurora PostgreSQL RDS and RDS security groups using module |
| providers.tf | `root/terraform/` | AWS providers for multiregion deployments using aliases |
| vpc.tf | `root/terraform/` | Creation of VPC/subnets using community modules |


### Architecture Diagram

![arch](https://user-images.githubusercontent.com/48310743/209669630-91800b4e-9747-4d6a-bfbe-bb947da0d22e.png)

#### Description

### Architecture for Multi Region(Including traffic distribution)

![MULTI ARCH](https://user-images.githubusercontent.com/48310743/209669985-5ab689e4-797d-484b-9ee4-f9eac262854f.png)

#### Description

### Kubernetes

#### Autoscaling

#### Securing ConfigMap