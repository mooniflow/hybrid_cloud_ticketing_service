resource "aws_route_table_association" "eks_rtta1" {
subnet_id = aws_subnet.eks_sub_controlplane1.id
route_table_id = aws_route_table.eks_rtta.id
}
resource "aws_route_table_association" "eks_rtta2" {
subnet_id = aws_subnet.eks_sub_controlplane2.id
route_table_id = aws_route_table.eks_rtta.id
}