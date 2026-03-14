resource "yandex_iam_service_account" "terraform" {
  name        = "admin"
  description = "Service account for Terraform"
}


resource "yandex_resourcemanager_folder_iam_member" "terraform_admin" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}
