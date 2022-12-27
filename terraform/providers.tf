#Declare multiple provider regions to provision multi region infrastructure. Just rememebr to add the alias in the resource/module when creating
#Refer to vpc.tf for example

provider "aws" {
    region  = "ap-southeast-1"
    alias   = "ap-southeast-1"
}

provider "aws" {
    region  = "us-west-1"
    alias   = "us-west-1"
}