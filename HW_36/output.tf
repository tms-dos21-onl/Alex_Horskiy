output "instance_names" {
  value = [for vm in module.vm_instances : vm.instance_name]
}

output "ip_addresses" {
  value = join(", ", [for vm in module.vm_instances : vm.nat_ip])
}