resource "aws_route_table_association" "team3_ngwrtas_worker1" {
subnet_id = aws_subnet.eks_sub_worker1.id
route_table_id = aws_route_table.team3_ngwrt1.id
}
resource "aws_route_table_association" "team3_ngwrtas_worker2" {
subnet_id = aws_subnet.eks_sub_worker2.id
route_table_id = aws_route_table.team3_ngwrt2.id
}
resource "aws_route_table_association" "team3_db_rtas" {
subnet_id = aws_subnet.db_sub1.id
route_table_id = aws_route_table.team3_ngwrt1.id
}
resource "aws_route_table_association" "team3_db_rtas2" {
subnet_id = aws_subnet.db_sub2.id
route_table_id = aws_route_table.team3_ngwrt2.id
}
