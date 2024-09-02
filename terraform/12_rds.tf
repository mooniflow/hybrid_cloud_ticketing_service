resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db2"
  subnet_ids = [aws_subnet.db_sub1.id, aws_subnet.db_sub2.id]
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier          = "database-2"
  engine                      = "aurora-mysql"
  engine_version              = "8.0.mysql_aurora.3.04.1"
  availability_zones          = ["ap-northeast-2a", "ap-northeast-2b"]  # 다중 AZ 설정
  database_name               = "recapark"
  master_username             = "admin"
  master_password             = "It12345!"
  preferred_backup_window     = "07:00-09:00"
  backup_retention_period     = 7
  port                        = 3306
  db_subnet_group_name        = "db2"
  vpc_security_group_ids      = [aws_security_group.team3_sg.id]
  storage_encrypted           = true
  apply_immediately           = true
  skip_final_snapshot         = true

 

}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count                     = 2
  cluster_identifier        = aws_rds_cluster.aurora_cluster.id
  identifier                = "database-2-instance-${count.index}"
  instance_class            = "db.t3.medium"  # 선택한 인스턴스 유형
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.1"
  publicly_accessible       = false
  db_subnet_group_name      = aws_rds_cluster.aurora_cluster.db_subnet_group_name
}