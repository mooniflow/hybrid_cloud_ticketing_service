resource "aws_vpc" "eks_vpc" {
cidr_block = var.cidr
enable_dns_hostnames = true
enable_dns_support = true
tags = {
Name = "${var.name}-vpc"
}
}