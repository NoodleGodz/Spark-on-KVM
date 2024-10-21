#!/bin/bash


numofslaves=$1


if [ -f variables.tf ]; then
  echo "Removing existing variables.tf"
  rm variables.tf
fi

master_ip="192.168.122.100"
slave_base_ip="192.168.122.101"

cat <<EOL > variables.tf
variable "vm_ips" {
  type    = list(string)
  default = [
    "$master_ip",  # IP for master VM
EOL

for ((i=0; i<$numofslaves; i++))
do
  slave_ip=$(printf "192.168.122.%d" $((101 + i)))
  echo "    \"$slave_ip\",  # IP for slave $((i+1)) VM" >> variables.tf
done

cat <<EOL >> variables.tf
  ]
}

variable "vm_hostname" {
  type    = list(string)
  default = [
    "master",  # Hostname for master VM
EOL


for ((i=0; i<$numofslaves; i++))
do
  echo "    \"slave$((i+1))\",  # Hostname for slave $((i+1)) VM" >> variables.tf
done


cat <<EOL >> variables.tf
  ]
}

variable "vm_num" {
  type    = number 
  default = $((numofslaves + 1))
}
EOL

echo "Generated variables.tf with 1 master and $numofslaves slaves."


inventory_file="./ansible/inventory.ini"


if [ -f "$inventory_file" ]; then
  echo "Removing existing $inventory_file"
  rm "$inventory_file"
fi


echo "[bigdata]" > "$inventory_file"


echo "master ansible_host=$master_ip ansible_user=ubuntu" >> "$inventory_file"


for ((i=0; i<$numofslaves; i++))
do
  slave_ip=$(printf "192.168.122.%d" $((101 + i)))
  echo "slave$((i + 1)) ansible_host=$slave_ip ansible_user=ubuntu" >> "$inventory_file"
done

echo "Generated $inventory_file with 1 master and $numofslaves slaves."


maid_file="./ansible/files/slaves"

if [ -f "$maid_file" ]; then
  echo "Removing existing $maid_file"
  rm "$maid_file"
fi

for ((i=0; i<$numofslaves; i++))
do
  echo "slave$((i + 1)) " >> "$maid_file"
done

echo "Generated $maid_file with $numofslaves slaves."
