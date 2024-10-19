
provider "libvirt" {
  uri = "qemu:///system"
}


# Define the base Ubuntu image volume
resource "libvirt_volume" "ubuntu_base_image" {
  name   = "ubuntu.qcow2"
  pool   = "home-pool"
  source = "/home/baybobi/Desktop/bigdata/ubuntu.qcow2"  # Path to your existing Ubuntu image
  format = "qcow2"
}

# Create separate disks for each VM, using the base image
resource "libvirt_volume" "vm_disk" {
  count  = var.vm_num
  name   = "vm-disk-${count.index}.qcow2"
  pool   = "home-pool"
  base_volume_id = libvirt_volume.ubuntu_base_image.id
  format = "qcow2"
}


resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.vm_num
  name  = "cloudinit-${count.index}.iso"
  pool  = "default"

  user_data = <<-EOF
    #cloud-config
    hostname: ${var.vm_hostname[count.index]} 
    ssh_pwauth: True
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh-authorized-keys:
          - ${file("${pathexpand("~/.ssh/id_rsa.pub")}")}  # Embed SSH public key

    network:
      version: 2
      ethernets:
        ens3:
          dhcp4: false
          optional: false
          addresses:
            - ${var.vm_ips[count.index]} 
          gateway4: 192.168.122.1 
          nameservers:
            addresses:
              - 8.8.8.8  # Google DNS
              - 8.8.4.4
          match:
            macaddress: "52:54:00:${count.index}:${count.index}:01"  # Match based on MAC
          set-name: ens3
    growpart:
      devices: [/]
      ignore_growroot_disabled: false
      mode: auto
  EOF
}

# Create 3 VMs
resource "libvirt_domain" "vm" {
  count  = var.vm_num
  name   = "simple-vm-${count.index}"
  memory = 1024 
  vcpu   = 1    
depends_on = [libvirt_cloudinit_disk.commoninit, libvirt_volume.vm_disk]

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = "default"
    mac          = "52:54:00:${count.index}:${count.index}:01"
    addresses    = ["${var.vm_ips[count.index]}"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }


}

