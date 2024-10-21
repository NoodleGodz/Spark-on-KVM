variable "vm_ips" {
  type    = list(string)
  default = [
    "192.168.122.100",  # IP for master VM
    "192.168.122.101",  # IP for slave 1 VM
    "192.168.122.102",  # IP for slave 2 VM
    "192.168.122.103",  # IP for slave 3 VM
  ]
}

variable "vm_hostname" {
  type    = list(string)
  default = [
    "master",  # Hostname for master VM
    "slave1",  # Hostname for slave 1 VM
    "slave2",  # Hostname for slave 2 VM
    "slave3",  # Hostname for slave 3 VM
  ]
}

variable "vm_num" {
  type    = number 
  default = 4
}
