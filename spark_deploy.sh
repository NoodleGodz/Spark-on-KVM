
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <java_file or jar_file> <data_file> <number_of_slaves>"
    exit 1
fi

java_file=$1
data_file=$2
numofslaves=$3

. ./sh/terra_custom.sh $3

terraform init

terraform apply -auto-approve

echo "Wait 20 seconds for VM init before Ansible..."
sleep 20


ansible-playbook -i ansible/inventory.ini ansible/setup.yml -u ubuntu --private-key ~/.ssh/id_rsa


sleep 2

ansible-playbook -i ansible/inventory.ini ansible/spork_run.yml -u ubuntu --private-key ~/.ssh/id_rsa


vm_ip="192.168.122.100" 
vm_user="ubuntu"  

# Check file existed
if [[ ! -f "$java_file" ]]; then
    echo "Error: Java file '$java_file' not found!"
    terraform destroy -auto-approve
    exit 1
fi

if [[ ! -f "$data_file" ]]; then
    echo "Error: Data file '$data_file' not found!"
    terraform destroy -auto-approve
    exit 1
fi



echo "Transferring files to the Master..."

scp "$java_file" "$data_file" "$vm_user@$vm_ip:/home/$vm_user/"

if [ $? -eq 0 ]; then
    echo "Files transferred successfully!"
else
    echo "File transfer failed."
    terraform destroy -auto-approve
    exit 1
fi


if [[ $java_file == *.java ]]; then
    echo "Compiling and packaging the Java file on the Master..."
    ssh $vm_user@$vm_ip 'bash -s' < ./sh/comp.sh "$java_file"
fi


echo "Created Hdfs..."
ssh $vm_user@$vm_ip 'bash -s' << 'EOF'
hdfs namenode -format
start-dfs.sh
EOF

echo "Uploading the $data_file to Hdfs /input..."
ssh $vm_user@$vm_ip 'bash -s' < ./sh/copy.sh $data_file

echo "Initiating Spark..."
ssh $vm_user@$vm_ip 'bash -s' < ./sh/sparking.sh 


echo "Deploying tasks in Spark Clusters..."
ssh $vm_user@$vm_ip 'bash -s' < ./sh/submit.sh $java_file





echo "Merging outputs and downloading to local machine..."
if [[ ! -f ".output" ]]; then
    mkdir output
fi
sleep 3


scp -r "${vm_user}@${vm_ip}:/tmp/output/output.txt" "./output/output.txt"



echo "Deprovision KVM..."
terraform destroy -auto-approve

echo "Result is at /output/"