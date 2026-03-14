variable "name" {
  type        = string
  description = "Instance name"
}

variable "cpu" {
  type        = number
  description = "Number of cpu cores"
  default     = 2
}

variable "ram" {
  type        = number
  description = "Number of RAM"
  default     = 2
}

variable "zone" {
  type        = string
  description = "Server zone"
  default     = "ru-central1-a"
}

variable "image_id" {
  type        = string
  description = "Server OS image"
}

variable "subnet_id" {
  type        = string
  description = "Server subnet"
}

variable "core_fraction" {
  type        = number
  description = "How many percent of cpu power will be used by vm"
  default     = 100
}

variable "install_ansible" {
  type        = bool
  description = "Install ansible on current vm or not"
  default     = true
}

variable "hdd_size" {
  type        = number
  description = "HDD size of vm"
  default     = 50
}

variable "ssh_user" {
  type = string
}

variable "ssh_key_path" {
  type        = string
  description = "Path of ssh key"
  default     = "C:/Users/Maxim/.ssh/id_ed25519.pub"
}
