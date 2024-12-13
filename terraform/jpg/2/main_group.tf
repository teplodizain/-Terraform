// описание сервисного аккаунта
resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

// описание прав доступа к каталогу
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id  = "b1gs8gks9evl3v7ufrrl"
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
  depends_on = [
    yandex_iam_service_account.ig-sa,
  ]
}

// описание группы ВМ
resource "yandex_compute_instance_group" "ig-1" {
  name                = "fixed-ig"
  folder_id           = "b1gs8gks9evl3v7ufrrl"
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"
  deletion_protection = false
  depends_on          = [yandex_resourcemanager_folder_iam_member.editor]
  
  //Шаблон ВМ
  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }

    network_interface {
      network_id         = "${yandex_vpc_network.network-1.id}"
      subnet_ids         = ["${yandex_vpc_subnet.subnet-1.id}"]
      nat                = true    
    }


    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data  = <<EOF
#!/bin/bash
sudo apt install nginx -y
runcmd:
  export PUBLIC_IPV4=$(curl ifconfig.me)
  echo Instance:$(hostname).IP Adress $PUBLIC_IPV4 > /var/www/html/index.html
  
sudo service nginx start
sudo echo '<html><head><title>Savchenko</title></head>' >> /var/www/html/index.html
sudo echo '<body><h1>Netology</h1> <body><h1>Savchenko</h1><img src="http://${yandex_storage_bucket.test.bucket_domain_name}/111.png"/></body></html>' >> /var/www/html/index.html

EOF      
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

     health_check {
        http_options {
            port    = 80
            path    = "/"
        }
    }

  load_balancer {
      target_group_name = "target-group"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}
