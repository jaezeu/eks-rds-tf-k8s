#Created these resources outside of this terraform
#S3 backend to store terraform state
#DynamoDB(Use LockID as hash key) to lock terraform statefile, this would prevent multiple people from editting the same statefile


# terraform {
#   backend "s3" {
#     bucket          = "dev-tf-state-bucket-6752349823649" //S3 Bucket Name
#     key             = "tf/terraform.tfstate"
#     encrypt         = "true"
#     dynamodb_table  = "tf_state_lock_table" //DynamoDB Table Name    
#   }
# }