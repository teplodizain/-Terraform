locals {
  ssh-keys = file("~/.ssh/id_rsa.pub")
  ssh-private-keys = file("~/.ssh/id_rsa")
}

# Содаем диск
resource "yandex_compute_disk" "boot-disk-1" {
  name     = "${var.name_disk}-1"
  type     = var.type_disk
  zone     = var.zone
  size     = "20"
  image_id = var.image_id_disk
}



# Считывает данные об образе ОС 1
resource "yandex_compute_instance" "vm-1-public" {
  # разрешение на остановку работы виртуальной машины для внесения изменений.
  allow_stopping_for_update = true
  name = "terraform1-public"
  hostname = "vm-1-public"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1-public.id
    # Чтобы автоматически назначить ВМ публичный IP-адрес, укажите
    nat       = true
  }
  
  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
  }

  # Чтобы создать прерываемую ВМ
  scheduling_policy {
    preemptible = true
  }
  
}


# Считывает данные об образе ОС 2
resource "yandex_compute_instance" "vm-2-private" {
  # разрешение на остановку работы виртуальной машины для внесения изменений.
  allow_stopping_for_update = true
  name = "terraform2-private"
  hostname = "vm-2-private"


  resources {
    cores  = 4
    memory = 4
  }


  boot_disk {
    initialize_params {
      name     = "${var.name_disk}-2"
      type     = var.type_disk
      size     = "20"
      image_id = var.image_id_disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2-private.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
  }
    # Чтобы создать прерываемую ВМ
  scheduling_policy {
    preemptible = true
  }
}
