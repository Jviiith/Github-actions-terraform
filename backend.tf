#Terraform apply to Set Up remote backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create S3 
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "terraform-state-bucket-demo"
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create DynamoDB Table
resource "aws_dynamodb_table" "dynamodb_table_statelock" {
  name         = "state-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
