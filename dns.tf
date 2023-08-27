resource "aws_service_discovery_service" "sonar" {
  name  = "sonar"

  dns_config {
    namespace_id = local.namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}