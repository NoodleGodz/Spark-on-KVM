# Spark Cluster Deployment Script

We developed a script to deploy applications on a KVM-based Spark cluster and retrieve the output, using the following syntax:
```
./spark_deploy.sh <java_file or jar_file> <data_file> <number_of_slaves>
```
### Parameters:
- `<java_file or jar_file>`: The `.java` file to compile and run, or an already compiled `.jar` file. The `.jar` filename must match the class name for execution.
- `<data_file>`: The data file to process, which will be uploaded to HDFS under `hdfs://input/<data_file>`.
- `<number_of_slaves>`: Specifies the number of slave VMs to provision in the cluster. The script will create `(number_of_slaves + 1)` VMs, including the master, each with one core.

### Script Tasks

This script performs the following tasks in sequence:

1. **Updates Terraform and Ansible configuration files** to match the specified number of slave VMs.
2. **Provisions (number_of_slaves + 1) VMs** using Terraform, with IPs starting from `192.168.128.100` for the master, incrementing for each slave. All VMs use the Ubuntu 20.04 server image with extended storage space.
3. **Configures passwordless SSH access** between the VMs using Ansible, both for the host and between the VMs.
4. **Copies and installs JDK 8u202, Hadoop 2.7.1, and Spark 2.4.3** from the local directory, and configures all necessary `.xml` files for the Spark cluster.
5. **Transfers files to the master**, compiles and packages the Java file if needed.
6. **Deploys the Hadoop file system** and uploads the data file to `hdfs://input/<data_file>`.
7. **Initiates Spark** and executes the application across the Spark cluster.
8. **Merges the output into a single file** and downloads it to the local machine.
9. **Deprovisions all VMs**.

### Additional Resources

We also provide bash scripts to:
- Download the Ubuntu 20.04 server image to the `image/` directory.
- Download all necessary installation files for JDK 8u202, Hadoop 2.7.1, and Spark 2.4.3 to the `install/` directory.

### Output

The result file can be found in the `output/` directory.

### Test Run

Terminal output from a test run with 5 slave VMs can be accessed at the following link: [Test Run Output](https://github.com/NoodleGodz/Spark-on-KVM/tree/main/cleaned_output_5_slaves.txt)

