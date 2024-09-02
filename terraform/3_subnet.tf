resource "aws_subnet" "eks_sub_controlplane1" {
vpc_id = aws_vpc.eks_vpc.id
cidr_block = "10.3.0.0/20"
availability_zone = "ap-northeast-2a"
map_public_ip_on_launch = true
tags = {
Name = "${var.name}-subnet-public1-ap-northeast-2a"
}
}
resource "aws_subnet" "eks_sub_controlplane2" {
vpc_id = aws_vpc.eks_vpc.id
cidr_block = "10.3.16.0/20"
availability_zone = "ap-northeast-2b"
map_public_ip_on_launch = true
tags = {
Name = "${var.name}-subnet-private4-ap-northeast-2b"
}
}
resource "aws_subnet" "eks_sub_worker1" {
vpc_id = aws_vpc.eks_vpc.id
cidr_block = "10.3.128.0/20"
availability_zone = "ap-northeast-2a"

tags = {
Name = "${var.name}-subnet-private1-ap-northeast-2a"
}
}
resource "aws_subnet" "eks_sub_worker2" {
vpc_id = aws_vpc.eks_vpc.id
cidr_block = "10.3.144.0/20"
availability_zone = "ap-northeast-2b"

tags = {
Name = "${var.name}-subnet-private1-ap-northeast-2b"
}
}
resource "aws_subnet" "db_sub1" {
vpc_id = aws_vpc.eks_vpc.id
cidr_block = "10.3.160.0/20"
availability_zone = "ap-northeast-2a"
tags = { 
Name = "${var.name}-subnet-private1-ap-northeast-2a"
}
}
resource "aws_subnet" "db_sub2" {
vpc_id = aws_vpc.eks_vpc.id
cidr_block = "10.3.176.0/24"
availability_zone = "ap-northeast-2b"
tags = {
Name = "${var.name}-subnet-private1-ap-northeast-2b"
}
}