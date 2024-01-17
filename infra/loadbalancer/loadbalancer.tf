data "oci_core_instances" "instances" {
  compartment_id = var.compartment_id
}

resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = var.compartment_id
  display_name   = "k8s-nlb"
  subnet_id      = var.public_subnet_id

  is_private                     = false
  is_preserve_source_destination = false
}

resource "oci_network_load_balancer_backend_set" "nlb_backend_set" {
  health_checker {
    protocol = "TCP"
  }
  name                     = "k8s-backend-set-giropops-senhas"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"
  depends_on               = [oci_network_load_balancer_network_load_balancer.nlb]

  is_preserve_source = false
}

resource "oci_network_load_balancer_backend" "nlb_backend" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = var.node_port
  depends_on               = [oci_network_load_balancer_backend_set.nlb_backend_set]
  count                    = var.node_size
  target_id                = data.oci_core_instances.instances.instances[count.index].id
}

resource "oci_network_load_balancer_listener" "nlb_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set.name
  name                     = "k8s-nlb-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = var.listerner_port
  protocol                 = "TCP"
  depends_on               = [oci_network_load_balancer_backend.nlb_backend]
}

# Locust
resource "oci_network_load_balancer_backend_set" "nlb_backend_set_locust" {
  health_checker {
    protocol = "TCP"
    port     = 10256
  }
  name                     = "k8s-backend-set-locust"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"

  is_preserve_source = false
  depends_on               = [oci_network_load_balancer_listener.nlb_listener]
}

resource "oci_network_load_balancer_backend" "nlb_backend_locust" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set_locust.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = 31601
  depends_on               = [oci_network_load_balancer_backend_set.nlb_backend_set_locust]
  count                    = var.node_size
  target_id                = data.oci_core_instances.instances.instances[count.index].id
}

resource "oci_network_load_balancer_listener" "nlb_listener_locust" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set_locust.name
  name                     = "k8s-nlb-listener-locust"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = "3000"
  protocol                 = "TCP"
  depends_on               = [oci_network_load_balancer_backend.nlb_backend_locust]
}

# Prometheus
resource "oci_network_load_balancer_backend_set" "nlb_backend_set_prometheus" {
  health_checker {
    protocol = "TCP"
    port     = 10256
  }
  name                     = "k8s-backend-set-prometheus"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"

  is_preserve_source = false
  depends_on               = [oci_network_load_balancer_listener.nlb_listener_locust]
}

resource "oci_network_load_balancer_backend" "nlb_backend_prometheus" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set_prometheus.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = 31602
  depends_on               = [oci_network_load_balancer_backend_set.nlb_backend_set_prometheus]
  count                    = var.node_size
  target_id                = data.oci_core_instances.instances.instances[count.index].id
}

resource "oci_network_load_balancer_listener" "nlb_listener_prometheus" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set_prometheus.name
  name                     = "k8s-nlb-listener-prometheus"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = "3001"
  protocol                 = "TCP"
  depends_on               = [oci_network_load_balancer_backend.nlb_backend_prometheus]
}

# Grafana
resource "oci_network_load_balancer_backend_set" "nlb_backend_set_grafana" {
  health_checker {
    protocol = "TCP"
    port     = 10256
  }
  name                     = "k8s-backend-set-grafana"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"

  is_preserve_source = false
  depends_on               = [oci_network_load_balancer_listener.nlb_listener_prometheus]
}

resource "oci_network_load_balancer_backend" "nlb_backend_grafana" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set_grafana.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = 31603
  depends_on               = [oci_network_load_balancer_backend_set.nlb_backend_set_grafana]
  count                    = var.node_size
  target_id                = data.oci_core_instances.instances.instances[count.index].id
}

resource "oci_network_load_balancer_listener" "nlb_listener_grafana" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set_grafana.name
  name                     = "k8s-nlb-listener-grafana"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = "3002"
  protocol                 = "TCP"
  depends_on               = [oci_network_load_balancer_backend.nlb_backend_grafana]
}

# Alertmanager
resource "oci_network_load_balancer_backend_set" "nlb_backend_set_alertmanager" {
  health_checker {
    protocol = "TCP"
    port     = 10256
  }
  name                     = "k8s-backend-set-alertmanager"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"

  is_preserve_source = false
  depends_on               = [oci_network_load_balancer_listener.nlb_listener_grafana]
}

resource "oci_network_load_balancer_backend" "nlb_backend_alertmanager" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set_alertmanager.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = 31604
  depends_on               = [oci_network_load_balancer_backend_set.nlb_backend_set_alertmanager]
  count                    = var.node_size
  target_id                = data.oci_core_instances.instances.instances[count.index].id
}

resource "oci_network_load_balancer_listener" "nlb_listener_alertmanager" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set_alertmanager.name
  name                     = "k8s-nlb-listener-alertmanager"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = "3003"
  protocol                 = "TCP"
  depends_on               = [oci_network_load_balancer_backend.nlb_backend_alertmanager]
}
