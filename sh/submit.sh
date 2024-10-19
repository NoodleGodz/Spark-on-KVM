

java_file=$1

echo $(basename $java_file .java) 

spark-submit --class $(basename $java_file .java) --master spark://master:7077 wc.jar


hdfs dfs -getmerge /output/ /tmp/output/output.txt

