output "id" {
  value = yandex_compute_instance.instance.id
}

output "internal_ip" {
  value = yandex_compute_instance.instance.network_interface[0].ip_address
}

output "external_ip" {
  value = yandex_compute_instance.instance.network_interface[0].nat_ip_address
}

output "subnet_id" {
  value = var.subnet_id
}

output "ssh_user" {
  value = var.ssh_user
}
