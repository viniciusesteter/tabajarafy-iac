provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.main.token
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

terraform {
  backend "s3" {
    bucket = "tabajarafy-tf-state"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}