resource "aws_ecs_cluster" "devops_tools" {
  name = "devops_tools"
}

###

resource "aws_ecs_task_definition" "sonar" {
  family = "sonar"
  requires_compatibilities = [
    "FARGATE",
  ]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.sonar_ecs_task.arn
  network_mode       = "awsvpc"
  cpu                = 1024
  memory             = 4096

  container_definitions = jsonencode([
    {
      name        = "sonar"
      image       = "sonarqube:community"
      essential   = true
      cpu         = 0
      volumesFrom = []

      mountPoints = [
        {
          containerPath = "/opt/sonarqube/data"
          sourceVolume  = "data"
        },
        {
          containerPath = "/opt/sonarqube/extensions"
          sourceVolume  = "extensions"
        },
        {
          containerPath = "/opt/sonarqube/logs"
          sourceVolume  = "logs"
        }
      ]

      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 9000
          hostPort      = 9000
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.sonar.name
          awslogs-stream-prefix = "sonar"
          awslogs-region        = "ap-southeast-1"
        }
      }

      environment = [ 
      {
        "name" = "SONARQUBE_JDBC_USERNAME",
        "value" = local.sonar_db_username
      },
      { 
        "name" = "SONARQUBE_JDBC_PASSWORD",
        "value" = local.sonar_db_password
      },
      {
        "name" = "SONARQUBE_JDBC_URL",
        "value" = "jdbc:mysql://${aws_rds_cluster.aurora_db.endpoint}/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true"
      }
    ]
    }
  ])

  tags = {}


  dynamic "volume" {
    for_each = local.sonar_efs_access_mount_point
    content {
      name = volume.key

      efs_volume_configuration {
        file_system_id     = aws_efs_file_system.efs_volume.id
        root_directory     = "${volume.value}"
        transit_encryption = "ENABLED"

        authorization_config {
          access_point_id = aws_efs_access_point.sonar["${volume.key}"].id
        }
      }
    }
  }

}


resource "aws_ecs_service" "sonar" {
  name                 = "sonar"
  cluster              = aws_ecs_cluster.devops_tools.id
  task_definition      = aws_ecs_task_definition.sonar.arn
  desired_count        = 1
  platform_version     = "1.4.0"
  launch_type          = "FARGATE"
  force_new_deployment = true

  network_configuration {
    security_groups = local.ecs_sg_ids
    subnets          = local.ecs_subnet_ids
    /* assign_public_ip = true */
  }

  load_balancer {
    container_name   = "sonar"
    container_port   = 9000
    target_group_arn = aws_lb_target_group.example.arn
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sonar.arn
  }

  depends_on = [aws_lb_listener.sonar]
}