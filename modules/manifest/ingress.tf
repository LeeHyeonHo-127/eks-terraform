# resource "kubernetes_ingress_v1" "echoserver" {
#   metadata {
#     name      = "echoserver"
#     namespace = "echoserver"

#     annotations = {
#       "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
#       "alb.ingress.kubernetes.io/subnets"     = "subnet-0c036157664e890b7, subnet-06c0836a074054660, subnet-0c64e19e84f5d0461"
#       "alb.ingress.kubernetes.io/tags"        = "Environment=dev,Team=test"
#       "alb.ingress.kubernetes.io/target-type" = "ip"
#     }
#   }

#   spec {
#     ingress_class_name = "alb"

#     rule {
#       http {
#         path {
#           path      = "/"
#           path_type = "Exact"

#           backend {
#             service {
#               name = "echoserver"

#               port {
#                 number = 80
#               }
#             }
#           }
#         }

#         path {
#           path      = "/user"
#           path_type = "Exact"

#           backend {
#             service {
#               name = "echoserver"

#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

