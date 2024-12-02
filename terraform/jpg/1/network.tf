
# Создаем облачную сеть
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

# Создаем подсеть 1
resource "yandex_vpc_subnet" "subnet-1-public" {
  name           = "subnet1-public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  }

# Создаем подсеть 2
resource "yandex_vpc_subnet" "subnet-2-private" {
  name           = "subnet2-private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  route_table_id = yandex_vpc_route_table.nat-route-table.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}


resource "yandex_vpc_gateway" "egress-gateway" {
  name = "egress-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat-route-table" {
  network_id = yandex_vpc_network.network-1.id
  name           = "nat-route-table"


  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = "${yandex_vpc_gateway.egress-gateway.id}"
  }
}
