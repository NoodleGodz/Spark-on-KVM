
javac -cp ".:$SPARK_HOME/jars/spark-core_2.11-2.4.3.jar:$SPARK_HOME/jars/scala-library-2.11.12.jar:$HADOOP_HOME/share/hadoop/common/hadoop-common-2.7.1.jar" $1

jar cf wc.jar *.class
rm *.class
