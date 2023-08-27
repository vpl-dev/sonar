#----------------------------------------
# ECS security-group loop back rule to connect to EFS Volume
#----------------------------------------
resource "aws_security_group_rule" "ecs_loopback_rule" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = "-1"
  self                      = true
  description               = "Loopback"
  security_group_id         = "${local.ecs_sg_ids[0]}"
}

resource "aws_efs_file_system" "efs_volume" {
  performance_mode = "generalPurpose"

  creation_token = "efs-volume"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
 
}

resource "aws_efs_mount_target" "ecs_temp_space_az0" {
  file_system_id = "${aws_efs_file_system.efs_volume.id}"
  subnet_id      = local.ecs_subnet_ids[0]
  security_groups = local.ecs_sg_ids
}

resource "aws_efs_mount_target" "ecs_temp_space_az1" {
  file_system_id = "${aws_efs_file_system.efs_volume.id}"
  subnet_id      = local.ecs_subnet_ids[1]
  security_groups = local.ecs_sg_ids
}

resource "aws_efs_access_point" "sonar" {
  for_each = local.sonar_efs_access_mount_point
  file_system_id = aws_efs_file_system.efs_volume.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
      permissions = "755"
    }
    path = "${each.value}"
  }

  tags = {
    Name = "${each.key}"
  }
}