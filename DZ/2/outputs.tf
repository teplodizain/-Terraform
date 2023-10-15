output "one_VM" {
  value = yandex_compute_instance.platform.network_interface.0.nat_ip_address

}

output "two_vm" {
  value = yandex_compute_instance.platform_2.network_interface.0.nat_ip_address

}