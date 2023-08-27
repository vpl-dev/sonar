locals {
  vpc_id = "vpc-xxxxx"
  alb_subnet_ids = ["subnet-xxxxx", "subnet-xxxxx"]
  ecs_subnet_ids = ["subnet-xxxxx", "subnet-xxxxx"]
  db_subnet_ids = ["subnet-xxxxx", "subnet-xxxxx"]
  alb_sg_ids = ["sg-xxxxx", "sg-xxxxx"]
  ecs_sg_ids = ["sg-xxxxx"]
  db_sg_ids = ["sg-xxxxx"]

  sonar_db_engine_version = "15.3"
  sonar_db_name = "sonar"
  sonar_db_username = "sonar"
  sonar_db_password = "sonar1111111111"
  sonar_db_instance_size = "db.t3.large"

  namespace_id = "ns-cjy4mqxvuyqzq6mc"

  sonar_efs_access_mount_point = {
    "data" = "/opt/sonarqube/data",
    "extensions" = "/opt/sonarqube/extensions",
    "logs" = "/opt/sonarqube/logs"
  }
}