# # data "aws_lb" "ingress" {
# #   depends_on = [ data.kubernetes_ingress_v1.ingress ]
# #   name = "${local.name_prefix}-alb"
# # }

# resource "kubernetes_namespace" "echoserver" {
#   metadata {
#     name = "echoserver"
#   }

#   depends_on = [ 
#     aws_eks_cluster.eks,
#     aws_eks_node_group.eks,
#     null_resource.kubeconfig 
#     ]
# }

# resource "kubernetes_deployment" "echoserver" {
#   metadata {
#     name      = "echoserver"
#     namespace = "echoserver"
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "echoserver"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "echoserver"
#         }
#       }

#       spec {
#         container {
#           name  = "nodejs"
#           image = "registry.k8s.io/hpa-example"

#           port {
#             container_port = 80
#           }

#           resources {
#             limits = {
#               cpu    = "1000m"
#               memory = "200Mi"
#             }

#             requests = {
#               cpu    = "250m"
#               memory = "100Mi"
#             }
#           }

#           image_pull_policy = "Always"
#         }
#       }
#     }
#   }

#   depends_on = [ kubernetes_namespace.echoserver ]
# }



# resource "kubernetes_service" "echoserver" {
#   metadata {
#     name      = "echoserver"
#     namespace = "echoserver"
#   }

#   spec {
#     port {
#       protocol    = "TCP"
#       port        = 80
#       target_port = "80"
#     }

#     selector = {
#       app = "echoserver"
#     }

#     type = "NodePort"
#   }

#   # depends_on = [ kubernetes_deployment.echoserver ]
# }

# resource "kubernetes_ingress_v1" "echoserver" {
#   metadata {
#     name      = "echoserver"
#     namespace = "echoserver"

#     annotations = {
#       "alb.ingress.kubernetes.io/load-balancer-name"    = "${local.name_prefix}-alb"
#       "alb.ingress.kubernetes.io/group.name"            = "${local.name_prefix}"
#       "alb.ingress.kubernetes.io/scheme"                = "internet-facing"
#       "alb.ingress.kubernetes.io/subnets"               = join(",", var.public_subnet_ids)
#       "alb.ingress.kubernetes.io/tags"                  = "Environment=dev,Team=test"
#       "alb.ingress.kubernetes.io/target-type"           = "ip"
#       "alb.ingress.kubernetes.io/healthcheck-path"      =  "/"
#       "alb.ingress.kubernetes.io/healthcheck-protocol"  =  "HTTP"
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
#           path      = "/signup"
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
#           path      = "/kakao"
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
#           path      = "/login"
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
#           path      = "/signin"
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
#           path      = "/pricing"
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
#           path      = "/payment"
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

#   depends_on = [ kubernetes_service.echoserver ]
# }

