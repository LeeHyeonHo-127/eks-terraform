# resource "kubernetes_horizontal_pod_autoscaler_v1" "echoserver" {
#   metadata {
#     name      = "echoserver"
#     namespace = "echoserver"
#   }

#   spec {
#     scale_target_ref {
#       kind        = "Deployment"
#       name        = "echoserver"
#       api_version = "apps/v1"
#     }

#     min_replicas = 1
#     max_replicas = 2

#       target_cpu_utilization_percentage = 10
#   }

#   depends_on = [ 
#     kubernetes_deployment.echoserver
#      ]

# }

