wget http://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img -O ubuntu.qcow2

#may need this, add more storage to image
#qemu-img resize ubuntu.qcow2 +5G

#also may need this, default pool is small, better to move it to /home for more space
#sudo mkdir -p /home/libvirt-images
#sudo virsh pool-define-as home-pool dir - - - - "/home/libvirt-images"
#sudo virsh pool-start home-pool
#sudo virsh pool-autostart home-pool

#if no need, change the main.tf file pool from home-pool to default

