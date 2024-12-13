resource "yandex_lb_network_load_balancer" "foo" {
  name = "savchenko-load-balancer"
  deletion_protection = false
  
  //параметры обработчика:
  listener {
    name = "lb-listener-netology-savchenko"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  //  описание параметров целевой группы для сетевого балансировщика:
  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-1.load_balancer[0].target_group_id    
    
    healthcheck {
      name = "savchenko"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
  depends_on = [
    yandex_compute_instance_group.ig-1
]
}
