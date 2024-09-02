resource "aws_route_table" "eks_rtta" {
vpc_id = aws_vpc.eks_vpc.id
route {
cidr_block = var.rtcidr
gateway_id = aws_internet_gateway.eks_ig.id
}
tags = {
Name = "${var.name}-rtb-public"
}
}