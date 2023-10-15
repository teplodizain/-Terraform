resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family1
 
}


# VM1

resource "yandex_compute_instance" "platform" {
  name        = local.VM1_name
  platform_id = var.vm_web_platform_id1
  allow_stopping_for_update = true
  

   resources {
    cores         = var.vm_web_resources["cpu"]
    memory        = var.vm_web_resources["ram"]
    core_fraction = var.vm_web_resources["core_fraction"]
  }


  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
    
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = var.vm_db_metadata["serial-port-enable"]
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}


# VM2

resource "yandex_compute_instance" "platform_2" {
  name        = local.VM2_name
  platform_id = var.vm_db_platform_id
  allow_stopping_for_update = true

   resources {
    cores         = var.vm_db_resources["cpu"]
    memory        = var.vm_db_resources["ram"]
    core_fraction = var.vm_db_resources["core_fraction"]
  }

/*
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

*/

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
    
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}