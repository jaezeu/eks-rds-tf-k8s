variable "sg_name" {
    description = "Name of the security group"
}
variable "vpc_id" {
    description = "VPC ID of the vpc to create security group in"
}
variable "security_group" {
    description = "Security group rules"
}