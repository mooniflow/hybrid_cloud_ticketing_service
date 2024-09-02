resource "aws_eip" "team3_eip1" {
domain = "vpc"
}
resource "aws_eip" "team3_eip2" {
domain = "vpc"
}
resource "aws_nat_gateway" "team3_ngw1" {
allocation_id = aws_eip.team3_eip1.id
subnet_id = aws_subnet.eks_sub_controlplane1.id
tags = {
Name = "${var.name}-nat-public1-ap-northeast-2a"
}
}
resource "aws_nat_gateway" "team3_ngw2" {
allocation_id = aws_eip.team3_eip2.id
subnet_id = aws_subnet.eks_sub_controlplane2.id
tags = {
Name = "${var.name}-nat-public2-ap-northeast-2b"
}
}
output "eip1" {
value = aws_eip.team3_eip1.public_ip
}
output "eip2" {
value = aws_eip.team3_eip2.public_ip
}

