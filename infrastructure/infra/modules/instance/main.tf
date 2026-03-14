terraform {
  required_version = "=1.14.3"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.177.0"
    }
  }
}

resource "yandex_compute_instance" "instance" {
 name = var.name 
 zone = var.zone

 resources {
     core_fraction = var.core_fraction
     cores         = var.cpu
     memory        = var.ram
   }

boot_disk {
  initialize_params {
    image_id = var.image_id
    size     = var.hdd_size
  }
}

network_interface {
  subnet_id = var.subnet_id
  nat       = true
  }
metadata = {
  ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
}

resource "null_resource" "ansible_install" {
  count = var.install_ansible ? 1 : 0

  provisioner "remote-exec" {
    inline  = var.install_ansible ? [
      "sudo apt update",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "sudo useradd -m -s /bin/bash -G sudo ansible", 
      "sudo mkdir -p /home/ansible/.ssh",
      "sudo cp /root/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys",
      "sudo chown -R ansible:ansible /home/ansible/.ssh"
    ] : []  

    connection {
      type        = "ssh"
      user        = "ubuntu" 
      private_key = file("C:/Users/Maxim/.ssh/id_ed25519")
      host        = yandex_compute_instance.instance.network_interface.0.nat_ip_address
   }
  } 
 }

   

