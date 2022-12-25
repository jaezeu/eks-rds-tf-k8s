# terraform {
#   backend "s3" {
#     bucket          = "dev-tf-state-bucket-6752349823649" //S3 Bucket Name
#     key             = "tf/terraform.tfstate"
#     encrypt         = "true"
#     dynamodb_table  = "tf_state_lock_table" //DynamoDB Table Name    
#   }
# }