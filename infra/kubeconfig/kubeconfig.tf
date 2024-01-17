resource "null_resource" "create_kubeconfig" {
  provisioner "local-exec" {
    command = "oci ce cluster create-kubeconfig --cluster-id ${var.cluster_id} --file ~/.kube/config --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
  }
}

# resource "null_resource" "install_cert_manager" {
#   depends_on = [ null_resource.create_kubeconfig ]
#   provisioner "local-exec" {
#     command = "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml && sleep 90"
#   }
# }

# resource "kubernetes_namespace" "giropops-senhas" {
#   depends_on = [null_resource.install_cert_manager]
#   metadata {
#     name = "giropops-senhas"
#   }
# }

# resource "null_resource" "issuer" {
#   depends_on = [kubernetes_namespace.giropops-senhas]

#   provisioner "local-exec" {
#     command = "kubectl apply -f ../manifests/Issuers/staging_issuer.yaml && kubectl apply -f ../manifests/Issuers/production_issuer.yaml"
#   }
# }

# modified command to work with fish shell
# resource "null_resource" "install_kube_prometheus" {
#   depends_on = [null_resource.create_kubeconfig]

#   provisioner "local-exec" {
#     command = "git clone https://github.com/prometheus-operator/kube-prometheus.git; and cd kube-prometheus; and kubectl create -f manifests/setup; and while not kubectl get servicemonitors --all-namespaces; date; sleep 1; echo ''; end; and kubectl apply -f manifests/; and cd ..; and rm -rf kube-prometheus"
#   }
# }
resource "null_resource" "install_kube_prometheus" {
  depends_on = [null_resource.create_kubeconfig]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "git clone https://github.com/prometheus-operator/kube-prometheus.git && cd kube-prometheus && kubectl create -f manifests/setup && while ! kubectl get servicemonitors --all-namespaces; do date; sleep 1; echo ''; done && kubectl apply -f manifests/ && cd .. && rm -rf kube-prometheus"
  }
}



resource "null_resource" "apply_manifests" {
  depends_on = [null_resource.install_kube_prometheus]

  provisioner "local-exec" {
    command = "kubectl apply -k ../manifests/overlays/oke"
  }
}
