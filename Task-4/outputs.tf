output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = yandex_vpc_network.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = yandex_vpc_subnet.private.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = yandex_vpc_gateway.nat_gateway.id
}

output "vm_internal_ip" {
  description = "Internal IP address of VM"
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
}

output "vm_id" {
  description = "ID of the VM"
  value       = yandex_compute_instance.vm.id
}

output "disk_id" {
  description = "ID of the disk"
  value       = yandex_compute_disk.vm_disk.id
}
