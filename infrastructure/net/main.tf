resource "yandex_vpc_network" "vpc" {
  name = "vpc-net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["10.100.14.0/24"]
}




