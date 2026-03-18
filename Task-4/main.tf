terraform {
  required_version = ">= 1.0"
  
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "main" {
  name = "${var.project_name}-network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.project_name}-public-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.project_name}-nat-gateway"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "${var.project_name}-nat-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "private" {
  name           = "${var.project_name}-private-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

resource "yandex_compute_disk" "vm_disk" {
  name     = "${var.project_name}-vm-disk"
  type     = "network-ssd"
  zone     = var.zone
  size     = var.disk_size
  image_id = var.ubuntu_image_id
}

resource "yandex_compute_instance" "vm" {
  name        = "${var.project_name}-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.vm_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}
