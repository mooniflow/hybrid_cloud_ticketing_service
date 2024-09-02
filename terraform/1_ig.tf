resource "aws_internet_gateway" "eks_ig" {
vpc_id = aws_vpc.eks_vpc.id
tags = {
Name = "${var.name}-igw"
}
}