## Quick Overview

This would provide a quick overview of the code in this repo. For more detailed breakdown of the code/file structure, please refer to the next section on GitHub File/Folder Structure.

For the kubernetes manifest files, I have separated them into individual files for ease of reading and management.(Deployment, Service, Ingress, HPA, ConfigMap)

For the terraform files, I have created 2 custom modules for security group & RDS. These can be found in the modules folder as "Security_group" & "aurora". Whereas for the VPC and EKS deployments, I am making use of the publicly available terraform AWS modules. Moreover, I have also split the terraform files by the name of the resources, for ease of management as well.

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

For the architecture above, I have created a VPC as well as 2 public subnets and 2 private subnets. The public subnets were used to host the EKS Cluster and worker nodes(Resources in `eks.tf`) as they are used to serve a public application. The worker nodes are also placed in a cluster autoscaler as part of the public terraform module, to ensure fault tolerance. The private subnets are used to hold the Aurora PostgreSQL database(Refer to `postgres.tf` for resource creation).

### Architecture for Multi Region(Including traffic distribution)

![MULTI ARCH](https://user-images.githubusercontent.com/48310743/209669985-5ab689e4-797d-484b-9ee4-f9eac262854f.png)

#### Description

Based on the multi-region architecture above, I have added multiple provider blocks in `provider.tf` file to ensure the code can be deployed to both the us-west1 and ap-southeast-1 region. Each time I have to deploy resources in a particular region, I just have to provider the alias of the corresponding region. I have also created an example implementation in `vpc.tf` where I tried deploying the VPC module in 2 regions.

With regards to splitting traffic or having a multi-region active-active infrastructure, I would make use of Route53 and add records of the AWS ALB Ingress urls of both the EKS clusters in each region and make use of the Route53 routing policies if required.(For e.g. using 50/50 weighted routing policies between 2 regions OR Geolocation routing )

### Kubernetes

#### Autoscaling

I have also added in a HorizontalPodAutoscaler(File in `hpa.yaml`) to scale the deployment based on cpu utilization 50%. Alternatively this can also be performed using kubectl imperative command: `kubectl autoscale deployment defi-api-deployment --cpu-percent=50 --min=1 --max=10` 

#### Securing ConfigMap

Firstly, I feel that it is important to know when to use ConfigMaps and what to store in them, as configmaps may not be the best secure storage mechanism , especially to store sensitive data. In our current use case as seen in `configmap.yaml`, one of the parameters is the database password(Despite being empty). To store sensitive information, It would be better to store them as secrets, especially using an external secrets store such as the Google Secret Manager or the AWS Secret Manager. In our current use case, since our infrastructure resides in AWS, I would use AWS secrets manager. To achieve this, I would make use of the "Kubernetes Secret Store CSI Driver", as seen in https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html. This method integrates secrets stores with Kubernetes via a Container Volume Interface(CSI) volume, which loads secrets from AWS Secrets Manager and mount them on the required workload(E.g. pod) using mounted volumes. With regards to controlling access, I would also make sure of IAM Roles for Service Accounts (IRSA) which is a feature provided by AWS. Using IRSA, I can grant IAM policies to IAM roles based on principle of least privilege, which corresponds to service accounts used in Kubernetes.