variable "cloud_id" {
  description = "Yandex cloud id"
  type        = string
  sensitive   = true
}

variable "folder_id" {
  description = "Yandex folder id"
  type        = string
  sensitive   = true
}

variable "sa_key_file" {
  type = string
}
