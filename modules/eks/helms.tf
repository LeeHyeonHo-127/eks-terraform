# data "kubernetes_ingress_v1" "ingress" {
#   depends_on = [ kubernetes_ingress_v1.echoserver ]

#   metadata {
#     name = "${local.name_prefix}-alb"
#   }
# }

# data "aws_lb" "ingress" {
#   depends_on = [ data.kubernetes_ingress_v1.ingress ]
#   name = "${local.name_prefix}-alb"
# }

# resource "time_sleep" "wait_for_alb" {
#   depends_on = [kubernetes_ingress_v1.echoserver]
#   create_duration = "90s"
# }

# ################### Prometheus
# resource "kubernetes_namespace" "prometheus" {

#   metadata {
#     name = "prometheus"
#   }
#   depends_on = [aws_eks_node_group.eks,
#                 data.aws_lb.ingress,
#                ]
# }
# ####################################### Prometheus

# resource "helm_release" "prometheus" {
#   depends_on = [aws_eks_node_group.eks,
#                 kubernetes_namespace.prometheus,
#                 data.aws_lb.ingress,
#                ]
  
#   name = "prometheus"
#   namespace  = "prometheus"
  
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"

#   # set {
#   #   name  = "prometheus.service.type"
#   #   value = "NodePort"
#   # }

#   set {
#     name  = "alertmanager.alertmanagerSpec.routePrefix"
#     value = "/alertmanager"
#   }

#   set {
#     name  = "prometheus.prometheusSpec.routePrefix"
#     value = "/prometheus"
#   }

#   set {
#     name  = "prometheus.ingress.enabled"
#     value = "true"
#   }
#   set {
#     name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
#     value = "${local.name_prefix}-alb"
#   }
#   set {
#     name  = "prometheus.ingress.ingressClassName"
#     value = "alb"
#   }
#   set_list {
#     name  = "prometheus.ingress.paths"
#     value = ["/alertmanager", "/prometheus"]
#   }
#   set {
#     name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
#     value = "internet-facing"
#   }
#   set {
#     name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
#     value = "ip"
#   }
#   set {
#     name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
#     value = "${local.name_prefix}"
#   }
#   set {
#     name  = "grafana.ingress.enabled"
#     value = "true"
#   }

#   set {
#     name  = "grafana.ingress.ingressClassName"
#     value = "alb"
#   }
#   set {
#     name  = "grafana.grafana\\.ini.server.domain"
#     value = "${data.aws_lb.ingress.dns_name}"
#   } 
#   set {
#     name  = "grafana.grafana\\.ini.server.root_url"
#     value = "http://${data.aws_lb.ingress.dns_name}/grafana"
#   }
#   set {
#     name  = "grafana.grafana\\.ini.server.serve_from_sub_path"
#     value = "true"
#   }
#   set {
#     name  = "grafana.ingress.path"
#     value = "/grafana"
#   }
#   set {
#     name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
#     value = "internet-facing"
#   }
#   set {
#     name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
#     value = "ip"
#   }
#   set {
#     name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
#     value = "${local.name_prefix}"
#   }  
#   set {
#     name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
#     # value = "infra-dev-ingress"
#     value = "${local.name_prefix}-alb"
#   }
# }


# ################### ArgoCD
# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }
# ################################### ArgoCD 
# resource "helm_release" "argocd" {
#   depends_on = [aws_eks_node_group.eks, # VPC 보다 먼저 생성 방지
#                 kubernetes_namespace.argocd,
#                 data.aws_lb.ingress,
#                ]
  
#   name = "argocd"
#   namespace  = "argocd"
  
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"

#   set {
#     name  = "configs.params.server\\.insecure"
#     value = "true"
#   }
#   set {
#     name  = "configs.params.server\\.rootpath"
#     value = "/argocd"
#   }
#   set {
#     name  = "global.domain"
#     value = ""
#   }
#   set {
#     name  = "server.ingress.enabled"
#     value = "true"
#   }
#   set {
#     name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
#     value = "${local.name_prefix}-alb"
#   }
#   set {
#     name  = "server.ingress.ingressClassName"
#     value = "alb"
#   }
#   set {
#     name  = "server.ingress.path"
#     value = "/argocd"
#   }
#   set {
#     name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
#     value = "internet-facing"
#   }
#   set {
#     name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
#     value = "ip"
#   }
#   set {
#     name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
#     value = "${local.name_prefix}"
#   }
# }
