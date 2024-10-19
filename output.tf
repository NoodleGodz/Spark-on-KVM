

output "hello"{
	value = "im tired"
}


output "vm_details" {
  value = [
    for i in range(var.vm_num) : {
      ip       = length(libvirt_domain.vm[i].network_interface) > 0 && length(libvirt_domain.vm[i].network_interface[0].addresses) > 0 ? libvirt_domain.vm[i].network_interface[0].addresses[0] : "Not assigned"
      hostname = var.vm_hostname[i]  # Assuming you have a list of hostnames defined
    }
  ]
}
