resource "aws_route_table" "team3_ngwrt1" {
vpc_id = aws_vpc.eks_vpc.id
route {
cidr_block = var.rtcidr
nat_gateway_id = aws_nat_gateway.team3_ngw1.id
}
tags = {
Name = "${var.name}-rtb-private1-ap-northeast-2a"
}
}

resource "aws_route_table" "team3_ngwrt2" {
vpc_id = aws_vpc.eks_vpc.id
route {
cidr_block = var.rtcidr
nat_gateway_id = aws_nat_gateway.team3_ngw2.id
}
tags = {
Name = "${var.name}-rtb-private2-ap-northeast-2b"
}
}