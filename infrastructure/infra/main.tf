module "master" {
  source           = "./modules/instance"
  name             = "master"
  subnet_id        = data.yandex_vpc_subnet.subnet.id
  image_id         = data.yandex_compute_image.ubuntu.id
  ssh_user         = "ubuntu"
}
module "app" {
  source           = "./modules/instance"
  name             = "app"
  subnet_id        = data.yandex_vpc_subnet.subnet.id
  image_id         = data.yandex_compute_image.ubuntu.id
  ssh_user         = "ubuntu"
}

module "srv" {
  source           = "./modules/instance"
  name             = "srv"
  subnet_id        = data.yandex_vpc_subnet.subnet.id
  image_id         = data.yandex_compute_image.ubuntu.id
  ssh_user         = "ubuntu"
  ram              = 4 
}

resource "local_file" "inventory" {
  depends_on = [
    module.master, 
    module.app,
    module.srv
  ]

  filename = "ansible/inventory.ini"
  content  = <<-EOF
    [kubernetes]
    master ansible_host=${module.master.external_ip} internal_ip=${module.master.internal_ip} ansible_user=${module.master.ssh_user}
    app ansible_host=${module.app.external_ip} internal_ip=${module.app.internal_ip} ansible_user=${module.app.ssh_user}

    [service]
    srv ansible_host=${module.srv.external_ip} internal_ip=${module.srv.internal_ip} ansible_user=${module.srv.ssh_user}
  EOF
}
  
data "yandex_vpc_subnet" "subnet" {
  name = "subnet"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}


