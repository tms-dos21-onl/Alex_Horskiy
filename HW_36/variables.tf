variable "machine_type" {
  description = "Тип/размер виртуальной машины"
  type        = string
}

variable "zone" {
  description = "Название availability zone"
  type        = string
}

variable "enable_public_ip" {
  description = "Создание публичного IP адреса"
  type        = bool
}

variable "image_family" {
  description = "Семейство образа виртуальной машины"
  type        = string
}

variable "image_project" {
  description = "Проект образа виртуальной машины"
  type        = string
}

variable "project_id" {
  description = "ID проекта в GCP"
  type        = string
}

variable "region" {
  description = "Регион в GCP"
  type        = string
}

