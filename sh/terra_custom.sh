#!/bin/bash

# Argument for the number of slave VMs
numofslaves=$1

# Check if variables.tf exists and delete it
if [ -f variables.tf ]; then
  echo "Removing existing variables.tf"
  rm variables.tf
fi

# Base IPs for the VMs (assuming master IP is fixed and starting IP for slaves is defined)
master_ip="192.168.122.100"
slave_base_ip="192.168.122.101"

# Generate the variables.tf file
cat <<EOL > variables.tf
variable "vm_ips" {
  type    = list(string)
  default = [
    "$master_ip",  # IP for master VM
EOL

# Loop to generate the IPs for slave VMs
for ((i=0; i<$numofslaves; i++))
do
  # Calculate the slave IP by incrementing the base IP
  slave_ip=$(printf "192.168.122.%d" $((101 + i)))
  echo "    \"$slave_ip\",  # IP for slave $((i+1)) VM" >> variables.tf
done

# Close the vm_ips list
cat <<EOL >> variables.tf
  ]
}

variable "vm_hostname" {
  type    = list(string)
  default = [
    "master",  # Hostname for master VM
EOL

# Loop to generate the hostnames for slave VMs
for ((i=0; i<$numofslaves; i++))
do
  echo "    \"slave$((i+1))\",  # Hostname for slave $((i+1)) VM" >> variables.tf
done

# Close the vm_hostname list
cat <<EOL >> variables.tf
  ]
}

variable "vm_num" {
  type    = number 
  default = $((numofslaves + 1))
}
EOL

echo "Generated variables.tf with 1 master and $numofslaves slaves."
