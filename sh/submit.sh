

java_file=$1



base_name=$(basename "$java_file" .java)
base_name=$(basename "$base_name" .jar)

echo $base_name

spark-submit --class $base_name --master spark://master:7077 $base_name.jar


hdfs dfs -getmerge /output/ /tmp/output/output.txt

