terraform {
  backend "s3" {
    bucket         = "<BUCKET_NAME>"
    region         = "<REGION>"
    dynamodb_table = "<TABLE_NAME>"
  }
}