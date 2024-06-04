variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_s3_bucket" {
  description = "S3 Bucket for tf.state"
}
