#------------------------------------------------------------------------------
# AWS KMS Encryption Key
#------------------------------------------------------------------------------
resource "aws_kms_key" "encryption_key" {
  description         = "Sonar Encryption Key"
  is_enabled          = true
  enable_key_rotation = true
}

#------------------------------------------------------------------------------
# AWS RDS Subnet Group
#------------------------------------------------------------------------------
resource "aws_db_subnet_group" "aurora_db_subnet_group" {
  name       = "sonar-aurora-db-subnet-group"
  subnet_ids = local.db_subnet_ids
}

#------------------------------------------------------------------------------
# AWS RDS Aurora Cluster
#------------------------------------------------------------------------------
resource "aws_rds_cluster" "aurora_db" {
  depends_on = [aws_kms_key.encryption_key]

  # Cluster
  cluster_identifier     = "sonar-aurora-db"
  vpc_security_group_ids = local.db_sg_ids
  db_subnet_group_name   = aws_db_subnet_group.aurora_db_subnet_group.id
  deletion_protection    = true

  # Encryption
  storage_encrypted = true
  kms_key_id        = aws_kms_key.encryption_key.arn

  # Database
  engine          = "aurora-postgresql"
  engine_version  = local.sonar_db_engine_version
  database_name   = local.sonar_db_name
  master_username = local.sonar_db_username
  master_password = local.sonar_db_password
skip_final_snapshot = false
  # Backups
}

#------------------------------------------------------------------------------
# AWS RDS Aurora Cluster Instances
#------------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "aurora_db_cluster_instances" {
  count                = 1
  identifier           = "aurora-db-instance"
  cluster_identifier   = aws_rds_cluster.aurora_db.id
  db_subnet_group_name = aws_db_subnet_group.aurora_db_subnet_group.id
  engine               = "aurora-postgresql"
  engine_version       = local.sonar_db_engine_version
  instance_class       = local.sonar_db_instance_size
  publicly_accessible  = false
}